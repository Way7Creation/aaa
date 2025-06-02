<?php
namespace App\Services;

use App\Core\Database;
use App\Core\Logger;
use App\Core\Cache;
use OpenSearch\ClientBuilder;

class SearchService
{
    private static ?\OpenSearch\Client $client = null;

    public static function search(array $params): array
    {
        $requestId = uniqid('search_', true);
        $startTime = microtime(true);

        // ДОБАВЛЯЕМ ДИАГНОСТИКУ
        $diagnostics = [
            'request_id' => $requestId,
            'start_time' => date('Y-m-d H:i:s'),
            'params' => $params
        ];

        Logger::info("🔍 [$requestId] Search started", ['params' => $params]);

        try {
            $params = self::validateParams($params);
            $diagnostics['validated_params'] = $params;

            // Если нет поискового запроса, используем MySQL для листинга
            if (empty($params['q']) || strlen(trim($params['q'])) === 0) {
                Logger::info("📋 [$requestId] Empty query, using MySQL for listing");
                $diagnostics['search_method'] = 'mysql_listing';

                $result = self::searchViaMySQL($params);
                $result['diagnostics'] = $diagnostics;

                return [
                    'success' => true,
                    'data' => $result
                ];
            }

            // Парсим поисковый запрос
            $parsedQuery = self::parseSearchQuery($params['q']);
            $diagnostics['parsed_query'] = $parsedQuery;

            // Проверяем доступность OpenSearch
            $opensearchAvailable = self::isOpenSearchAvailable();
            $diagnostics['opensearch_available'] = $opensearchAvailable;

            if ($opensearchAvailable) {
                Logger::debug("✅ [$requestId] Using OpenSearch");
                $diagnostics['search_method'] = 'opensearch';

                try {
                    $result = self::performOpenSearchWithTimeout($params, $requestId, $parsedQuery);
                    $diagnostics['opensearch_success'] = true;
                    $result['diagnostics'] = $diagnostics;

                    $duration = round((microtime(true) - $startTime) * 1000, 2);
                    Logger::info("✅ [$requestId] OpenSearch completed in {$duration}ms");

                    return [
                        'success' => true,
                        'data' => $result
                    ];
                } catch (\Exception $e) {
                    Logger::warning("⚠️ [$requestId] OpenSearch failed, falling back to MySQL", [
                        'error' => $e->getMessage()
                    ]);
                    $diagnostics['opensearch_error'] = $e->getMessage();
                    $diagnostics['search_method'] = 'mysql_fallback';
                }
            } else {
                Logger::warning("⚠️ [$requestId] OpenSearch unavailable, using MySQL");
                $diagnostics['search_method'] = 'mysql_primary';
            }

            // MySQL поиск (основной или fallback)
            $result = self::searchViaMySQL($params);
            $result['diagnostics'] = $diagnostics;

            return [
                'success' => true,
                'data' => $result
            ];

        } catch (\Exception $e) {
            $duration = round((microtime(true) - $startTime) * 1000, 2);
            Logger::error("❌ [$requestId] Failed after {$duration}ms", [
                'error' => $e->getMessage()
            ]);

            $diagnostics['final_error'] = $e->getMessage();
            $diagnostics['search_method'] = 'error_fallback';

            // Всегда пробуем MySQL fallback при ошибке
            try {
                Logger::info("🔄 [$requestId] Trying MySQL fallback");
                $result = self::searchViaMySQL($params);
                $result['diagnostics'] = $diagnostics;

                return [
                    'success' => true,
                    'data' => $result,
                    'used_fallback' => true
                ];
            } catch (\Exception $fallbackError) {
                Logger::error("❌ [$requestId] MySQL fallback also failed", [
                    'error' => $fallbackError->getMessage()
                ]);

                $diagnostics['fallback_error'] = $fallbackError->getMessage();

                return [
                    'success' => false,
                    'error' => 'Search service temporarily unavailable',
                    'error_code' => 'SERVICE_UNAVAILABLE',
                    'data' => [
                        'products' => [],
                        'total' => 0,
                        'page' => $params['page'] ?? 1,
                        'limit' => $params['limit'] ?? 20,
                        'diagnostics' => $diagnostics
                    ]
                ];
            }
        }
    }

    /**
     * Улучшенный MySQL поиск с поддержкой транслитерации и исправления раскладки
     */
    private static function searchViaMySQL(array $params): array
    {
        $query = $params['q'] ?? '';
        $page = $params['page'];
        $limit = $params['limit'];
        $offset = ($page - 1) * $limit;

        try {
            $pdo = Database::getConnection();

            // Если нет поискового запроса - просто получаем список товаров
            if (empty($query)) {
                $sql = "SELECT SQL_CALC_FOUND_ROWS 
                        p.product_id, p.external_id, p.sku, p.name, p.description,
                        p.brand_id, p.series_id, p.unit, p.min_sale, p.weight, p.dimensions,
                        b.name as brand_name, s.name as series_name,
                        1 as relevance_score
                        FROM products p
                        LEFT JOIN brands b ON p.brand_id = b.brand_id
                        LEFT JOIN series s ON p.series_id = s.series_id
                        WHERE 1=1";

                $bindParams = [];
            } else {
                // Генерируем варианты запроса
                $searchVariants = self::generateSearchVariants($query);

                // Строим SQL с учетом всех вариантов
                $whereClauses = [];
                $bindParams = [];
                $paramIndex = 0;

                foreach ($searchVariants as $variant) {
                    $exactKey = "exact_{$paramIndex}";
                    $prefixKey = "prefix_{$paramIndex}";
                    $searchKey = "search_{$paramIndex}";

                    $whereClauses[] = "
                        p.external_id = :{$exactKey} OR
                        p.sku = :{$exactKey} OR
                        p.external_id LIKE :{$prefixKey} OR
                        p.sku LIKE :{$prefixKey} OR
                        p.name LIKE :{$searchKey} OR
                        p.description LIKE :{$searchKey} OR
                        b.name LIKE :{$searchKey}
                    ";

                    $bindParams[$exactKey] = $variant;
                    $bindParams[$prefixKey] = $variant . '%';
                    $bindParams[$searchKey] = '%' . $variant . '%';

                    $paramIndex++;
                }

                $sql = "SELECT SQL_CALC_FOUND_ROWS 
                        p.product_id, p.external_id, p.sku, p.name, p.description,
                        p.brand_id, p.series_id, p.unit, p.min_sale, p.weight, p.dimensions,
                        b.name as brand_name, s.name as series_name,
                        CASE 
                            WHEN p.external_id = :original_q THEN 1000
                            WHEN p.sku = :original_q THEN 900
                            WHEN p.external_id LIKE :original_prefix THEN 100
                            WHEN p.sku LIKE :original_prefix THEN 90
                            WHEN p.name = :original_q THEN 80
                            WHEN p.name LIKE :original_prefix THEN 50
                            WHEN p.name LIKE :original_search THEN 30
                            ELSE 1
                        END as relevance_score
                        FROM products p
                        LEFT JOIN brands b ON p.brand_id = b.brand_id
                        LEFT JOIN series s ON p.series_id = s.series_id
                        WHERE (" . implode(' OR ', $whereClauses) . ")";

                // Добавляем оригинальный запрос для скоринга
                $bindParams['original_q'] = $query;
                $bindParams['original_prefix'] = $query . '%';
                $bindParams['original_search'] = '%' . $query . '%';
            }

            // Сортировка
            switch ($params['sort']) {
                case 'name':
                    $sql .= " ORDER BY p.name ASC";
                    break;
                case 'external_id':
                    $sql .= " ORDER BY p.external_id ASC";
                    break;
                case 'popularity':
                    $sql .= " ORDER BY p.product_id DESC";
                    break;
                default:
                    if (!empty($query)) {
                        $sql .= " ORDER BY relevance_score DESC, p.name ASC";
                    } else {
                        $sql .= " ORDER BY p.product_id DESC";
                    }
                    break;
            }

            $sql .= " LIMIT :limit OFFSET :offset";

            $stmt = $pdo->prepare($sql);

            // Привязываем параметры поиска
            foreach ($bindParams as $key => $value) {
                $stmt->bindValue($key, $value);
            }

            $stmt->bindValue(':limit', $limit, \PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, \PDO::PARAM_INT);
            $stmt->execute();

            $products = $stmt->fetchAll();
            $total = $pdo->query("SELECT FOUND_ROWS()")->fetchColumn();

            Logger::info("MySQL search completed", [
                'query' => $query,
                'variants' => $searchVariants ?? [],
                'found' => count($products),
                'total' => $total
            ]);

            return [
                'products' => $products,
                'total' => (int)$total,
                'page' => $page,
                'limit' => $limit,
                'source' => 'mysql',
                'search_variants' => $searchVariants ?? []
            ];

        } catch (\Exception $e) {
            Logger::error('MySQL search failed', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Генерация вариантов поискового запроса
     */
    private static function generateSearchVariants(string $query): array
    {
        $variants = [$query]; // Оригинальный запрос

        // 1. Конвертация раскладки клавиатуры RU<->EN
        $layoutConverted = self::convertKeyboardLayout($query);
        if ($layoutConverted !== $query) {
            $variants[] = $layoutConverted;
        }

        // 2. Транслитерация RU->EN
        $transliterated = self::transliterate($query);
        if ($transliterated !== $query && $transliterated !== $layoutConverted) {
            $variants[] = $transliterated;
        }

        // 3. Обратная транслитерация EN->RU
        $cyrillic = self::toCyrillic($query);
        if ($cyrillic !== $query && !in_array($cyrillic, $variants)) {
            $variants[] = $cyrillic;
        }

        // 4. Удаление пробелов и спецсимволов для артикулов
        $normalized = preg_replace('/[^a-zA-Z0-9а-яА-Я]/u', '', $query);
        if ($normalized !== $query && !in_array($normalized, $variants)) {
            $variants[] = $normalized;
        }

        return array_unique($variants);
    }

    /**
     * Конвертация раскладки клавиатуры
     */
    private static function convertKeyboardLayout(string $text): string
    {
        $ru = 'йцукенгшщзхъфывапролджэячсмитьбю';
        $en = 'qwertyuiop[]asdfghjkl;\'zxcvbnm,.';

        $ruUpper = mb_strtoupper($ru);
        $enUpper = strtoupper($en);

        // RU -> EN
        $result = strtr($text, $ru . $ruUpper, $en . $enUpper);
        if ($result !== $text) {
            return $result;
        }

        // EN -> RU
        return strtr($text, $en . $enUpper, $ru . $ruUpper);
    }

    /**
     * Транслитерация RU -> EN
     */
    private static function transliterate(string $text): string
    {
        $rules = [
            'а' => 'a', 'б' => 'b', 'в' => 'v', 'г' => 'g', 'д' => 'd',
            'е' => 'e', 'ё' => 'e', 'ж' => 'zh', 'з' => 'z', 'и' => 'i',
            'й' => 'y', 'к' => 'k', 'л' => 'l', 'м' => 'm', 'н' => 'n',
            'о' => 'o', 'п' => 'p', 'р' => 'r', 'с' => 's', 'т' => 't',
            'у' => 'u', 'ф' => 'f', 'х' => 'h', 'ц' => 'ts', 'ч' => 'ch',
            'ш' => 'sh', 'щ' => 'sch', 'ъ' => '', 'ы' => 'y', 'ь' => '',
            'э' => 'e', 'ю' => 'yu', 'я' => 'ya'
        ];

        $text = mb_strtolower($text);
        return strtr($text, $rules);
    }

    /**
     * Обратная транслитерация EN -> RU (простая версия)
     */
    private static function toCyrillic(string $text): string
    {
        $rules = [
            'a' => 'а', 'b' => 'б', 'v' => 'в', 'g' => 'г', 'd' => 'д',
            'e' => 'е', 'z' => 'з', 'i' => 'и', 'k' => 'к', 'l' => 'л',
            'm' => 'м', 'n' => 'н', 'o' => 'о', 'p' => 'п', 'r' => 'р',
            's' => 'с', 't' => 'т', 'u' => 'у', 'f' => 'ф', 'h' => 'х',
            'c' => 'ц', 'y' => 'у'
        ];

        $text = strtolower($text);
        return strtr($text, $rules);
    }

    /**
     * Проверка доступности OpenSearch с кешированием
     */
    private static function isOpenSearchAvailable(): bool
    {
        static $isAvailable = null;
        static $lastCheck = 0;
        static $consecutiveFailures = 0;

        // Кеш проверки на 60 секунд при успехе, 10 секунд при неудаче
        $cacheTime = $isAvailable ? 60 : 10;

        if ($isAvailable !== null && (time() - $lastCheck) < $cacheTime) {
            return $isAvailable;
        }

        try {
            $startTime = microtime(true);
            $client = self::getClient();

            // Быстрая проверка ping
            $response = $client->ping();

            if ($response) {
                // Дополнительно проверяем здоровье кластера
                $health = $client->cluster()->health([
                    'timeout' => '2s'
                ]);

                $isAvailable = in_array($health['status'] ?? 'red', ['green', 'yellow']);

                if ($isAvailable) {
                    $consecutiveFailures = 0;
                    Logger::debug("✅ OpenSearch available", [
                        'ping_time_ms' => round((microtime(true) - $startTime) * 1000, 2),
                        'cluster_status' => $health['status'] ?? 'unknown'
                    ]);
                } else {
                    $consecutiveFailures++;
                    Logger::warning("⚠️ OpenSearch cluster not healthy", [
                        'status' => $health['status'] ?? 'unknown'
                    ]);
                }
            } else {
                $isAvailable = false;
                $consecutiveFailures++;
                Logger::warning("❌ OpenSearch ping failed");
            }

            $lastCheck = time();

        } catch (\Exception $e) {
            $isAvailable = false;
            $lastCheck = time();
            $consecutiveFailures++;

            Logger::error("❌ OpenSearch check failed", [
                'error' => $e->getMessage(),
                'consecutive_failures' => $consecutiveFailures
            ]);

            // После 5 неудачных попыток увеличиваем интервал проверки
            if ($consecutiveFailures >= 5) {
                $lastCheck = time() - 50; // Будет проверять раз в 10 секунд вместо каждого запроса
            }
        }

        return $isAvailable;
    }

    private static function getClient(): \OpenSearch\Client
    {
        if (self::$client === null) {
            self::$client = ClientBuilder::create()
                ->setHosts(['localhost:9200'])
                ->setRetries(1)
                ->setConnectionParams([
                    'timeout' => 5,
                    'connect_timeout' => 2
                ])
                ->build();
        }
        return self::$client;
    }

    private static function validateParams(array $params): array
    {
        return [
            'q' => trim($params['q'] ?? ''),
            'page' => max(1, (int)($params['page'] ?? 1)),
            'limit' => min(100, max(1, (int)($params['limit'] ?? 20))),
            'city_id' => (int)($params['city_id'] ?? 1),
            'sort' => $params['sort'] ?? 'relevance',
            'user_id' => $params['user_id'] ?? null
        ];
    }

    /**
     * 🔍 Умный парсер поискового запроса
     * 
     * Разбивает запрос на логические части:
     * - Числа с единицами (16А, 220В)
     * - Коды/артикулы (MVA40-1-016-C)
     * - Обычные слова (выключатель, автоматический)
     * 
     * @param string $query Поисковый запрос
     * @return array Структурированные части запроса
     */
    private static function parseSearchQuery(string $query): array
    {
        $query = trim($query);

        // Инициализируем результат
        $result = [
            'original' => $query,
            'words' => [],
            'numbers' => [],
            'codes' => [],
            'exact' => [],
            'cleaned' => ''
        ];

        if (empty($query)) {
            return $result;
        }

        // 1. Извлекаем точные фразы в кавычках
        if (preg_match_all('/"([^"]+)"/', $query, $matches)) {
            $result['exact'] = $matches[1];
            // Удаляем кавычки из основного запроса
            $query = preg_replace('/"[^"]+"/', '', $query);
        }

        // 2. Нормализуем запрос
        $normalized = preg_replace('/\s+/', ' ', trim($query));
        $result['cleaned'] = $normalized;

        // 3. Разбиваем на токены
        $tokens = preg_split('/[\s\-_,;.]+/', $normalized, -1, PREG_SPLIT_NO_EMPTY);

        foreach ($tokens as $token) {
            $token = trim($token);
            if (empty($token)) continue;

            // Проверяем, это число с единицами (16А, 220В, 2.5мм)
            if (preg_match('/^\d+([.,]\d+)?\s*[а-яА-Яa-zA-Z]*$/u', $token)) {
                $result['numbers'][] = $token;
            }
            // Проверяем, это код/артикул (содержит цифры, буквы, дефисы)
            elseif (preg_match('/^[a-zA-Z0-9\-_.]{3,}$/i', $token) && preg_match('/\d/', $token)) {
                $result['codes'][] = $token;
            }
            // Обычное слово
            else {
                $result['words'][] = $token;
            }
        }

        // 4. Убираем дубликаты
        $result['words'] = array_unique($result['words']);
        $result['numbers'] = array_unique($result['numbers']);
        $result['codes'] = array_unique($result['codes']);
        $result['exact'] = array_unique($result['exact']);

        return $result;
    }

    private const KNOWN_BRANDS = [
        'iek', 'karat', 'schneider', 'abb', 'legrand', 
        'русский свет', 'российский свет', 'russian light'
    ];

    /**
     * 🎨 Конфигурация подсветки найденных терминов в результатах поиска
     * 
     * Что это делает:
     * - Выделяет найденные слова в названии товара
     * - Подсвечивает совпадения в артикуле 
     * - Показывает релевантные части текста
     * 
     * @return array Конфигурация для OpenSearch highlight
     */
    private static function buildHighlightConfig(): array 
    {
        return [
            'fields' => [
                // Подсветка в названии товара (самое важное поле)
                'name' => [
                    'type' => 'unified',           // Самый быстрый тип подсветки
                    'number_of_fragments' => 0,   // Показываем весь текст, а не фрагменты
                    'pre_tags' => ['<mark>'],     // Открывающий тег подсветки
                    'post_tags' => ['</mark>']    // Закрывающий тег подсветки
                ],
                
                // Подсветка в артикуле (для точного поиска кодов)
                'external_id' => [
                    'type' => 'unified', 
                    'number_of_fragments' => 0,   // Артикул короткий - показываем весь
                    'pre_tags' => ['<mark>'],
                    'post_tags' => ['</mark>']
                ],
                
                // Подсветка в названии бренда
                'brand_name' => [
                    'type' => 'unified',
                    'number_of_fragments' => 0,
                    'pre_tags' => ['<mark>'],
                    'post_tags' => ['</mark>']
                ],
                
                // 🆕 ДОПОЛНИТЕЛЬНО: подсветка в описании (если есть)
                'description' => [
                    'type' => 'unified',
                    'number_of_fragments' => 2,   // Показываем 2 фрагмента описания
                    'fragment_size' => 150,       // Каждый фрагмент до 150 символов
                    'pre_tags' => ['<mark>'],
                    'post_tags' => ['</mark>']
                ]
            ],
            
            // Дополнительные настройки
            'require_field_match' => false,    // Подсвечиваем даже если совпадение в другом поле
            'fragment_size' => 150,            // Размер фрагмента по умолчанию
            'max_analyzed_offset' => 1000000   // Анализируем до 1М символов (для больших описаний)
        ];
    }

    private static function performOpenSearchWithTimeout(array $params, string $requestId, array $parsedQuery): array
    {
        $client = self::getClient();

        // 🔥 Основная структура запроса
        $body = [
            'timeout' => '15s',
            'size' => $params['limit'],
            'from' => ($params['page'] - 1) * $params['limit'],
            'track_total_hits' => true,
            '_source' => true
        ];

        if (!empty($params['q'])) {
            $query = trim($params['q']);

            // Создаем базовый запрос
            $baseQuery = [
                'bool' => [
                    'should' => [
                        // 1. ТОЧНОЕ совпадение артикула/SKU (максимальный приоритет)
                        [
                            'bool' => [
                                'should' => [
                                    ['term' => ['external_id.keyword' => ['value' => $query, 'boost' => 1000]]],
                                    ['term' => ['sku.keyword' => ['value' => $query, 'boost' => 900]]],
                                ]
                            ]
                        ],

                        // 2. ТОЧНАЯ фраза в названии
                        [
                            'match_phrase' => [
                                'name' => [
                                    'query' => $query,
                                    'boost' => 500,
                                    'slop' => 0
                                ]
                            ]
                        ],

                        // 3. ВСЕ слова должны быть (AND логика)
                        [
                            'match' => [
                                'name' => [
                                    'query' => $query,
                                    'operator' => 'and',
                                    'boost' => 200,
                                    'fuzziness' => 'AUTO'
                                ]
                            ]
                        ],

                        // 4. БОЛЬШИНСТВО слов (75%)
                        [
                            'match' => [
                                'name' => [
                                    'query' => $query,
                                    'minimum_should_match' => '75%',
                                    'boost' => 100,
                                    'fuzziness' => 'AUTO'
                                ]
                            ]
                        ],

                        // 5. Поиск по брендам
                        [
                            'match' => [
                                'brand_name' => [
                                    'query' => $query,
                                    'boost' => 80,
                                    'fuzziness' => 'AUTO'
                                ]
                            ]
                        ],

                        // 6. Поиск по категориям
                        [
                            'match' => [
                                'categories' => [
                                    'query' => $query,
                                    'boost' => 50
                                ]
                            ]
                        ],

                        // 7. Частичный поиск артикулов
                        [
                            'wildcard' => [
                                'external_id.keyword' => [
                                    'value' => "*{$query}*",
                                    'boost' => 150
                                ]
                            ]
                        ],

                        // 8. Автодополнение по названию
                        [
                            'match' => [
                                'name.autocomplete' => [
                                    'query' => $query,
                                    'boost' => 60
                                ]
                            ]
                        ],

                        // 9. Поиск в общем тексте
                        [
                            'match' => [
                                'search_text' => [
                                    'query' => $query,
                                    'boost' => 30,
                                    'fuzziness' => 'AUTO'
                                ]
                            ]
                        ],

                        // 10. Поиск в атрибутах
                        [
                            'nested' => [
                                'path' => 'attributes',
                                'query' => [
                                    'match' => [
                                        'attributes.value' => [
                                            'query' => $query,
                                            'boost' => 40
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ],
                    'minimum_should_match' => 1
                ]
            ];

            // Добавляем функциональный скоринг
            $body['query'] = [
                'function_score' => [
                    'query' => $baseQuery,
                    'functions' => [
                        // Буст для товаров в наличии
                        [
                            'filter' => ['term' => ['has_stock' => true]],
                            'weight' => 1.5
                        ],
                        // Буст по популярности
                        [
                            'field_value_factor' => [
                                'field' => 'popularity_score',
                                'modifier' => 'log1p',
                                'factor' => 1.2,
                                'missing' => 0
                            ]
                        ]
                    ],
                    'score_mode' => 'multiply',
                    'boost_mode' => 'multiply'
                ]
            ];

            // ✅ ПРАВИЛЬНО: добавляем подсветку ОТДЕЛЬНО
            $body['highlight'] = self::buildHighlightConfig();
        } else {
            // Без поискового запроса - просто листинг
            $body['query'] = ['match_all' => new \stdClass()];
        }

        // Сортировка
        if (!empty($params['q'])) {
            $body['sort'] = [
                ['_score' => 'desc'],
                ['has_stock' => 'desc'],
                ['popularity_score' => 'desc']
            ];
        } else {
            switch ($params['sort']) {
                case 'name':
                    $body['sort'] = [['name.keyword' => 'asc']];
                    break;
                case 'external_id':
                    $body['sort'] = [['external_id.keyword' => 'asc']];
                    break;
                default:
                    $body['sort'] = [['product_id' => 'desc']];
                    break;
            }
        }

        Logger::debug("[$requestId] OpenSearch query", ['body' => json_encode($body, JSON_PRETTY_PRINT)]);

        try {
            $response = $client->search([
                'index' => 'products_current',
                'body' => $body
            ]);

            // Обработка результатов
            $products = [];
            foreach ($response['hits']['hits'] ?? [] as $hit) {
                $product = $hit['_source'];
                $product['_score'] = $hit['_score'] ?? 0;

                // Добавляем подсветку
                if (isset($hit['highlight'])) {
                    $product['_highlight'] = $hit['highlight'];
                }

                $products[] = $product;
            }

            $total = $response['hits']['total']['value'] ?? 0;

            Logger::info("[$requestId] OpenSearch success", [
                'query' => $params['q'],
                'total' => $total,
                'returned' => count($products),
                'max_score' => $response['hits']['max_score'] ?? 0
            ]);

            return [
                'products' => $products,
                'total' => $total,
                'page' => $params['page'],
                'limit' => $params['limit'],
                'source' => 'opensearch',
                'max_score' => $response['hits']['max_score'] ?? 0
            ];

        } catch (\Exception $e) {
            Logger::error("[$requestId] OpenSearch failed", ['error' => $e->getMessage()]);
            throw $e;
        }
    }
}