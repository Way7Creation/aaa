-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Июн 02 2025 г., 19:13
-- Версия сервера: 8.0.42-0ubuntu0.22.04.1
-- Версия PHP: 8.1.2-1ubuntu2.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `mysql7648xk-yrsuqk7klp9fujg`
--

-- --------------------------------------------------------

--
-- Структура таблицы `application_logs`
--

CREATE TABLE `application_logs` (
  `id` bigint NOT NULL,
  `level` enum('emergency','alert','critical','error','warning','notice','info','debug') NOT NULL,
  `message` text NOT NULL,
  `context` json DEFAULT NULL,
  `extra` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `app_config`
--

CREATE TABLE `app_config` (
  `config_key` varchar(255) NOT NULL,
  `config_value` json NOT NULL,
  `description` text,
  `is_sensitive` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `audit_logs`
--

CREATE TABLE `audit_logs` (
  `log_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `object_type` varchar(50) NOT NULL,
  `object_id` int DEFAULT NULL,
  `details` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `brands`
--

CREATE TABLE `brands` (
  `brand_id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `logo_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `brand_prices`
--

CREATE TABLE `brand_prices` (
  `brand_price_id` int NOT NULL,
  `brand_id` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `valid_from` date NOT NULL,
  `valid_to` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `cache_entries`
--

CREATE TABLE `cache_entries` (
  `cache_key` varchar(255) NOT NULL,
  `cache_value` longtext NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `carts`
--

CREATE TABLE `carts` (
  `id` int NOT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `payload` json NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `cart_items`
--

CREATE TABLE `cart_items` (
  `cart_item_id` int NOT NULL,
  `session_id` varchar(128) NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price_snapshot` decimal(10,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cart_id` int NOT NULL
) ;

-- --------------------------------------------------------

--
-- Структура таблицы `categories`
--

CREATE TABLE `categories` (
  `category_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `parent_id` int DEFAULT NULL,
  `slug` varchar(100) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `cities`
--

CREATE TABLE `cities` (
  `city_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `region` varchar(100) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT 'Europe/Moscow',
  `delivery_base_days` int DEFAULT '1',
  `working_days` json DEFAULT NULL,
  `cutoff_time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `city_warehouse_mapping`
--

CREATE TABLE `city_warehouse_mapping` (
  `city_id` int NOT NULL,
  `warehouse_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `city_working_days`
--

CREATE TABLE `city_working_days` (
  `city_id` int NOT NULL,
  `weekday` tinyint(1) NOT NULL COMMENT '1=Mon…7=Sun',
  `hours` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `clients_organizations`
--

CREATE TABLE `clients_organizations` (
  `org_id` int NOT NULL,
  `user_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `city_id` int NOT NULL,
  `inn` varchar(12) NOT NULL,
  `kpp` varchar(9) NOT NULL,
  `address` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `client_prices`
--

CREATE TABLE `client_prices` (
  `price_id` int NOT NULL,
  `org_id` int NOT NULL,
  `product_id` int NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `valid_from` date NOT NULL,
  `valid_to` date DEFAULT NULL,
  `brand_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `delivery_schedules`
--

CREATE TABLE `delivery_schedules` (
  `schedule_id` int NOT NULL,
  `warehouse_id` int NOT NULL COMMENT 'Ссылка на склад',
  `city_id` int NOT NULL COMMENT 'Ссылка на город',
  `delivery_days` json NOT NULL COMMENT 'Дни доставки (1-пн, 7-вс)',
  `delivery_type` tinyint(1) NOT NULL COMMENT '1 — регулярная доставка, 0 — почта/ТК',
  `cutoff_time` time DEFAULT NULL COMMENT 'Время отсечки заказа (HH:MM:SS)',
  `is_express` tinyint(1) DEFAULT '0' COMMENT '1 — экспресс-доставка',
  `min_order_amount` decimal(10,2) DEFAULT NULL COMMENT 'Минимальная сумма заказа',
  `specific_dates` json DEFAULT NULL COMMENT '["2024-05-16", "2024-06-01"]',
  `delivery_mode` enum('weekly','specific_dates') DEFAULT 'weekly'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `email_logs`
--

CREATE TABLE `email_logs` (
  `id` int NOT NULL,
  `recipient` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `type` varchar(50) NOT NULL,
  `sent_at` datetime NOT NULL,
  `opened_at` datetime DEFAULT NULL,
  `clicked_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `job_queue`
--

CREATE TABLE `job_queue` (
  `id` int NOT NULL,
  `type` varchar(50) NOT NULL,
  `payload` json NOT NULL,
  `priority` tinyint NOT NULL DEFAULT '5',
  `available_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  `attempts` tinyint NOT NULL DEFAULT '0',
  `result` json DEFAULT NULL,
  `last_error` text,
  `created_at` datetime NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` int NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `failed_attempts` int NOT NULL DEFAULT '0',
  `last_attempt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `locked_until` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `metrics`
--

CREATE TABLE `metrics` (
  `id` bigint NOT NULL,
  `metric_type` varchar(50) NOT NULL,
  `data` json DEFAULT NULL,
  `value` float NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `prices`
--

CREATE TABLE `prices` (
  `price_id` int NOT NULL,
  `product_id` int NOT NULL,
  `supplier_name` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `valid_from` date NOT NULL,
  `valid_to` date DEFAULT NULL,
  `is_base` tinyint NOT NULL DEFAULT '0',
  `price_type` enum('base','special','client') DEFAULT 'base',
  `base_price` decimal(10,2) DEFAULT '0.00',
  `has_special` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `products`
--

CREATE TABLE `products` (
  `product_id` int NOT NULL,
  `external_id` varchar(50) NOT NULL,
  `sku` varchar(50) DEFAULT NULL,
  `name` varchar(500) NOT NULL,
  `brand_id` int DEFAULT NULL,
  `description` text,
  `unit` varchar(20) NOT NULL,
  `min_sale` int DEFAULT '1',
  `weight` decimal(10,2) DEFAULT NULL,
  `dimensions` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `series_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `product_attributes`
--

CREATE TABLE `product_attributes` (
  `attribute_id` int NOT NULL,
  `product_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `sort_order` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `product_categories`
--

CREATE TABLE `product_categories` (
  `product_id` int NOT NULL,
  `category_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `product_documents`
--

CREATE TABLE `product_documents` (
  `document_id` int NOT NULL,
  `product_id` int NOT NULL,
  `type` enum('certificate','manual','drawing') NOT NULL,
  `url` varchar(500) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `valid_to` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `product_images`
--

CREATE TABLE `product_images` (
  `image_id` int NOT NULL,
  `product_id` int NOT NULL,
  `url` varchar(500) NOT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT '0',
  `sort_order` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `product_metrics`
--

CREATE TABLE `product_metrics` (
  `product_id` int NOT NULL,
  `views_count` int DEFAULT '0',
  `cart_adds_count` int DEFAULT '0',
  `orders_count` int DEFAULT '0',
  `search_appearances` int DEFAULT '0',
  `popularity_score` decimal(5,2) DEFAULT '0.00',
  `last_calculated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `rate_limits`
--

CREATE TABLE `rate_limits` (
  `id` bigint NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `endpoint` varchar(255) NOT NULL,
  `requests_count` int NOT NULL DEFAULT '1',
  `window_start` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `related_products`
--

CREATE TABLE `related_products` (
  `relation_id` int NOT NULL,
  `product_id` int NOT NULL,
  `related_id` int NOT NULL,
  `relation_type` enum('similar','complementary','upsell') NOT NULL,
  `sort_order` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `roles`
--

CREATE TABLE `roles` (
  `role_id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `search_logs`
--

CREATE TABLE `search_logs` (
  `id` int NOT NULL,
  `query` varchar(500) NOT NULL,
  `results_count` int NOT NULL DEFAULT '0',
  `city_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `response_time_ms` int DEFAULT NULL COMMENT 'Время ответа в миллисекундах',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `series`
--

CREATE TABLE `series` (
  `series_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(128) NOT NULL,
  `data` longtext NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `user_id` int DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `specifications`
--

CREATE TABLE `specifications` (
  `specification_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `specification_items`
--

CREATE TABLE `specification_items` (
  `specification_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `stock_balances`
--

CREATE TABLE `stock_balances` (
  `stock_id` int NOT NULL,
  `product_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `reserved` int NOT NULL DEFAULT '0',
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Триггеры `stock_balances`
--
DELIMITER $$
CREATE TRIGGER `stock_balance_change_trigger` AFTER UPDATE ON `stock_balances` FOR EACH ROW BEGIN
    IF NEW.quantity != OLD.quantity OR NEW.reserved != OLD.reserved THEN
        INSERT INTO stock_change_log (product_id, processed) 
        VALUES (NEW.product_id, 0)
        ON DUPLICATE KEY UPDATE processed = 0;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `stock_change_log`
--

CREATE TABLE `stock_change_log` (
  `id` int NOT NULL,
  `product_id` int NOT NULL,
  `processed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `stock_history`
--

CREATE TABLE `stock_history` (
  `stock_history_id` int NOT NULL,
  `product_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `old_quantity` int NOT NULL,
  `new_quantity` int NOT NULL,
  `changed_by` int NOT NULL,
  `change_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `supplier_mappings`
--

CREATE TABLE `supplier_mappings` (
  `mapping_id` int NOT NULL,
  `product_id` int NOT NULL,
  `supplier_code` varchar(50) NOT NULL,
  `supplier_name` varchar(100) NOT NULL,
  `external_id` varchar(50) NOT NULL,
  `last_sync` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `user_id` int NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role_id` int NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_guest` tinyint(1) NOT NULL DEFAULT '0',
  `is_legal_entity` tinyint(1) NOT NULL DEFAULT '0',
  `inn` varchar(12) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `password_reset_token` varchar(255) DEFAULT NULL,
  `password_reset_expires` timestamp NULL DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `two_factor_secret` varchar(32) DEFAULT NULL,
  `two_factor_enabled` tinyint(1) DEFAULT '0',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `user_profiles`
--

CREATE TABLE `user_profiles` (
  `profile_id` int NOT NULL,
  `user_id` int NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `warehouses`
--

CREATE TABLE `warehouses` (
  `warehouse_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `city_id` int DEFAULT NULL,
  `address` text,
  `contact_phone` varchar(20) DEFAULT NULL,
  `working_hours` text,
  `is_active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `warehouse_delivery_dates`
--

CREATE TABLE `warehouse_delivery_dates` (
  `schedule_id` int NOT NULL,
  `dt` date NOT NULL,
  `cutoff_time` time DEFAULT NULL,
  `is_express` tinyint(1) NOT NULL DEFAULT '0',
  `min_order_amt` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `warehouse_delivery_days`
--

CREATE TABLE `warehouse_delivery_days` (
  `schedule_id` int NOT NULL,
  `weekday` tinyint(1) NOT NULL,
  `cutoff_time` time DEFAULT NULL,
  `is_express` tinyint(1) NOT NULL DEFAULT '0',
  `min_order_amt` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `application_logs`
--
ALTER TABLE `application_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_level_time` (`level`,`created_at`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Индексы таблицы `app_config`
--
ALTER TABLE `app_config`
  ADD PRIMARY KEY (`config_key`);

--
-- Индексы таблицы `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `ix_audit_logs_user` (`user_id`),
  ADD KEY `ix_audit_logs_object` (`object_type`,`object_id`),
  ADD KEY `ix_audit_logs_created` (`created_at`),
  ADD KEY `idx_audit_session` (`session_id`);

--
-- Индексы таблицы `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`brand_id`),
  ADD KEY `idx_brand_name` (`name`);

--
-- Индексы таблицы `brand_prices`
--
ALTER TABLE `brand_prices`
  ADD PRIMARY KEY (`brand_price_id`),
  ADD UNIQUE KEY `brand_id` (`brand_id`,`valid_from`);

--
-- Индексы таблицы `cache_entries`
--
ALTER TABLE `cache_entries`
  ADD PRIMARY KEY (`cache_key`),
  ADD KEY `idx_expires` (`expires_at`);

--
-- Индексы таблицы `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ux_cart_user` (`user_id`),
  ADD UNIQUE KEY `ux_cart_session` (`session_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_session_id` (`session_id`),
  ADD KEY `fk_carts_city` (`city_id`);

--
-- Индексы таблицы `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`cart_item_id`),
  ADD KEY `idx_product_session` (`product_id`,`session_id`) USING BTREE,
  ADD KEY `idx_product` (`product_id`),
  ADD KEY `idx_session` (`session_id`),
  ADD KEY `fk_cart_items_cart` (`cart_id`);

--
-- Индексы таблицы `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD UNIQUE KEY `ux_categories_slug` (`slug`),
  ADD KEY `idx_category_slug` (`slug`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Индексы таблицы `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`city_id`),
  ADD KEY `idx_city_name` (`name`);

--
-- Индексы таблицы `city_warehouse_mapping`
--
ALTER TABLE `city_warehouse_mapping`
  ADD PRIMARY KEY (`city_id`,`warehouse_id`),
  ADD KEY `fk_cwm_warehouse` (`warehouse_id`);

--
-- Индексы таблицы `city_working_days`
--
ALTER TABLE `city_working_days`
  ADD PRIMARY KEY (`city_id`,`weekday`);

--
-- Индексы таблицы `clients_organizations`
--
ALTER TABLE `clients_organizations`
  ADD PRIMARY KEY (`org_id`),
  ADD KEY `idx_orgs_user` (`user_id`),
  ADD KEY `idx_orgs_city` (`city_id`);

--
-- Индексы таблицы `client_prices`
--
ALTER TABLE `client_prices`
  ADD PRIMARY KEY (`price_id`),
  ADD KEY `idx_prices_org` (`org_id`),
  ADD KEY `fk_cp_product` (`product_id`),
  ADD KEY `ix_client_prices_org_prod` (`org_id`,`product_id`,`valid_from`),
  ADD KEY `fk_cp_brand` (`brand_id`),
  ADD KEY `idx_client_prices_lookup` (`org_id`,`product_id`,`valid_from`);

--
-- Индексы таблицы `delivery_schedules`
--
ALTER TABLE `delivery_schedules`
  ADD PRIMARY KEY (`schedule_id`),
  ADD UNIQUE KEY `uniq_schedule` (`warehouse_id`,`city_id`),
  ADD KEY `idx_delivery_schedule` (`warehouse_id`,`city_id`),
  ADD KEY `ix_ds_city_type` (`city_id`,`delivery_type`),
  ADD KEY `ix_ds_cutoff` (`cutoff_time`);

--
-- Индексы таблицы `email_logs`
--
ALTER TABLE `email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_recipient` (`recipient`),
  ADD KEY `idx_sent_at` (`sent_at`);

--
-- Индексы таблицы `job_queue`
--
ALTER TABLE `job_queue`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status_priority` (`status`,`priority`,`created_at`),
  ADD KEY `idx_type_status` (`type`,`status`);

--
-- Индексы таблицы `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_identifier` (`identifier`),
  ADD KEY `idx_last_attempt` (`last_attempt`);

--
-- Индексы таблицы `metrics`
--
ALTER TABLE `metrics`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_type_time` (`metric_type`,`created_at`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Индексы таблицы `prices`
--
ALTER TABLE `prices`
  ADD PRIMARY KEY (`price_id`),
  ADD UNIQUE KEY `product_id` (`product_id`,`supplier_name`,`valid_from`),
  ADD KEY `idx_product_valid` (`product_id`,`valid_from`,`valid_to`);

--
-- Индексы таблицы `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD UNIQUE KEY `external_id` (`external_id`),
  ADD UNIQUE KEY `ux_products_external_id` (`external_id`),
  ADD KEY `idx_sku` (`sku`),
  ADD KEY `idx_external_id` (`external_id`),
  ADD KEY `idx_brand` (`brand_id`),
  ADD KEY `fk_products_series` (`series_id`);
ALTER TABLE `products` ADD FULLTEXT KEY `ft_product_name` (`name`,`description`);
ALTER TABLE `products` ADD FULLTEXT KEY `ft_search` (`name`,`sku`,`external_id`);

--
-- Индексы таблицы `product_attributes`
--
ALTER TABLE `product_attributes`
  ADD PRIMARY KEY (`attribute_id`),
  ADD UNIQUE KEY `uniq_prod_attr` (`product_id`,`name`(100),`value`(255),`unit`),
  ADD KEY `idx_attribute_product` (`product_id`);

--
-- Индексы таблицы `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`product_id`,`category_id`),
  ADD KEY `fk_pc_category` (`category_id`);

--
-- Индексы таблицы `product_documents`
--
ALTER TABLE `product_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `idx_document_product` (`product_id`);

--
-- Индексы таблицы `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`image_id`),
  ADD KEY `idx_image_product` (`product_id`);

--
-- Индексы таблицы `product_metrics`
--
ALTER TABLE `product_metrics`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `idx_popularity` (`DESC`);

--
-- Индексы таблицы `rate_limits`
--
ALTER TABLE `rate_limits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_identifier_endpoint` (`identifier`,`endpoint`),
  ADD KEY `idx_window_start` (`window_start`);

--
-- Индексы таблицы `related_products`
--
ALTER TABLE `related_products`
  ADD PRIMARY KEY (`relation_id`),
  ADD UNIQUE KEY `unq_product_relation` (`product_id`,`related_id`,`relation_type`),
  ADD KEY `fk_rp_related` (`related_id`);

--
-- Индексы таблицы `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Индексы таблицы `search_logs`
--
ALTER TABLE `search_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_query` (`query`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_user_city` (`user_id`,`city_id`),
  ADD KEY `fk_search_logs_city` (`city_id`);

--
-- Индексы таблицы `series`
--
ALTER TABLE `series`
  ADD PRIMARY KEY (`series_id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `idx_series_name` (`name`);

--
-- Индексы таблицы `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `idx_expires` (`expires_at`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_ip_address` (`ip_address`);

--
-- Индексы таблицы `specifications`
--
ALTER TABLE `specifications`
  ADD PRIMARY KEY (`specification_id`),
  ADD KEY `idx_user_spec` (`user_id`);

--
-- Индексы таблицы `specification_items`
--
ALTER TABLE `specification_items`
  ADD PRIMARY KEY (`specification_id`,`product_id`),
  ADD KEY `fk_si_prod` (`product_id`),
  ADD KEY `idx_spec_product` (`specification_id`,`product_id`);

--
-- Индексы таблицы `stock_balances`
--
ALTER TABLE `stock_balances`
  ADD PRIMARY KEY (`stock_id`),
  ADD UNIQUE KEY `unq_stock_product` (`product_id`,`warehouse_id`),
  ADD KEY `idx_stock_warehouse` (`warehouse_id`),
  ADD KEY `idx_stock_product_warehouse` (`product_id`,`warehouse_id`),
  ADD KEY `idx_stock_product_warehouse_unique` (`product_id`,`warehouse_id`),
  ADD KEY `ix_stock_balances_prod_wh` (`product_id`,`warehouse_id`),
  ADD KEY `idx_product_warehouse_qty` (`product_id`,`warehouse_id`,`quantity`);

--
-- Индексы таблицы `stock_change_log`
--
ALTER TABLE `stock_change_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_processed` (`processed`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Индексы таблицы `stock_history`
--
ALTER TABLE `stock_history`
  ADD PRIMARY KEY (`stock_history_id`),
  ADD KEY `idx_stock_history` (`product_id`,`warehouse_id`),
  ADD KEY `warehouse_id` (`warehouse_id`),
  ADD KEY `ix_stock_history_time` (`change_time`);

--
-- Индексы таблицы `supplier_mappings`
--
ALTER TABLE `supplier_mappings`
  ADD PRIMARY KEY (`mapping_id`),
  ADD UNIQUE KEY `unq_supplier_mapping` (`supplier_name`,`external_id`),
  ADD KEY `idx_supplier_product` (`product_id`),
  ADD KEY `idx_supplier_external_id` (`external_id`),
  ADD KEY `idx_external_id` (`external_id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `ux_users_email` (`email`),
  ADD UNIQUE KEY `ux_users_username` (`username`),
  ADD KEY `idx_users_city` (`city_id`),
  ADD KEY `fk_users_role` (`role_id`),
  ADD KEY `idx_password_reset_token` (`password_reset_token`),
  ADD KEY `idx_email_verified` (`email_verified_at`);

--
-- Индексы таблицы `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`profile_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `warehouses`
--
ALTER TABLE `warehouses`
  ADD PRIMARY KEY (`warehouse_id`),
  ADD KEY `idx_warehouse_city` (`city_id`);

--
-- Индексы таблицы `warehouse_delivery_dates`
--
ALTER TABLE `warehouse_delivery_dates`
  ADD PRIMARY KEY (`schedule_id`,`dt`);

--
-- Индексы таблицы `warehouse_delivery_days`
--
ALTER TABLE `warehouse_delivery_days`
  ADD PRIMARY KEY (`schedule_id`,`weekday`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `application_logs`
--
ALTER TABLE `application_logs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `log_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `brands`
--
ALTER TABLE `brands`
  MODIFY `brand_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `brand_prices`
--
ALTER TABLE `brand_prices`
  MODIFY `brand_price_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `carts`
--
ALTER TABLE `carts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `cart_item_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `cities`
--
ALTER TABLE `cities`
  MODIFY `city_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `clients_organizations`
--
ALTER TABLE `clients_organizations`
  MODIFY `org_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `client_prices`
--
ALTER TABLE `client_prices`
  MODIFY `price_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `delivery_schedules`
--
ALTER TABLE `delivery_schedules`
  MODIFY `schedule_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `email_logs`
--
ALTER TABLE `email_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `job_queue`
--
ALTER TABLE `job_queue`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `metrics`
--
ALTER TABLE `metrics`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `prices`
--
ALTER TABLE `prices`
  MODIFY `price_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `product_attributes`
--
ALTER TABLE `product_attributes`
  MODIFY `attribute_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `product_documents`
--
ALTER TABLE `product_documents`
  MODIFY `document_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `product_images`
--
ALTER TABLE `product_images`
  MODIFY `image_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `rate_limits`
--
ALTER TABLE `rate_limits`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `related_products`
--
ALTER TABLE `related_products`
  MODIFY `relation_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `search_logs`
--
ALTER TABLE `search_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `series`
--
ALTER TABLE `series`
  MODIFY `series_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `specifications`
--
ALTER TABLE `specifications`
  MODIFY `specification_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `stock_balances`
--
ALTER TABLE `stock_balances`
  MODIFY `stock_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `stock_change_log`
--
ALTER TABLE `stock_change_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `stock_history`
--
ALTER TABLE `stock_history`
  MODIFY `stock_history_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `supplier_mappings`
--
ALTER TABLE `supplier_mappings`
  MODIFY `mapping_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `profile_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `warehouses`
--
ALTER TABLE `warehouses`
  MODIFY `warehouse_id` int NOT NULL AUTO_INCREMENT;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Ограничения внешнего ключа таблицы `brand_prices`
--
ALTER TABLE `brand_prices`
  ADD CONSTRAINT `fk_bp_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `fk_cart_session` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_carts_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`);

--
-- Ограничения внешнего ключа таблицы `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cart_items_cart` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`category_id`);

--
-- Ограничения внешнего ключа таблицы `city_warehouse_mapping`
--
ALTER TABLE `city_warehouse_mapping`
  ADD CONSTRAINT `city_warehouse_mapping_ibfk_1` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`),
  ADD CONSTRAINT `city_warehouse_mapping_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`),
  ADD CONSTRAINT `fk_cwm_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cwm_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `city_working_days`
--
ALTER TABLE `city_working_days`
  ADD CONSTRAINT `fk_cwd_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `clients_organizations`
--
ALTER TABLE `clients_organizations`
  ADD CONSTRAINT `clients_organizations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `clients_organizations_ibfk_2` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`),
  ADD CONSTRAINT `fk_co_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_co_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `client_prices`
--
ALTER TABLE `client_prices`
  ADD CONSTRAINT `client_prices_ibfk_1` FOREIGN KEY (`org_id`) REFERENCES `clients_organizations` (`org_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cp_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cp_org` FOREIGN KEY (`org_id`) REFERENCES `clients_organizations` (`org_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cp_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `delivery_schedules`
--
ALTER TABLE `delivery_schedules`
  ADD CONSTRAINT `delivery_schedules_ibfk_1` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`),
  ADD CONSTRAINT `delivery_schedules_ibfk_2` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`),
  ADD CONSTRAINT `fk_ds_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ds_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `prices`
--
ALTER TABLE `prices`
  ADD CONSTRAINT `fk_prices_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_series` FOREIGN KEY (`series_id`) REFERENCES `series` (`series_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_series` FOREIGN KEY (`series_id`) REFERENCES `series` (`series_id`),
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`);

--
-- Ограничения внешнего ключа таблицы `product_attributes`
--
ALTER TABLE `product_attributes`
  ADD CONSTRAINT `fk_pa_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `product_categories`
--
ALTER TABLE `product_categories`
  ADD CONSTRAINT `fk_pc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pc_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `product_documents`
--
ALTER TABLE `product_documents`
  ADD CONSTRAINT `fk_pd_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `fk_pi_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `product_metrics`
--
ALTER TABLE `product_metrics`
  ADD CONSTRAINT `product_metrics_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `related_products`
--
ALTER TABLE `related_products`
  ADD CONSTRAINT `fk_rp_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rp_related` FOREIGN KEY (`related_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `search_logs`
--
ALTER TABLE `search_logs`
  ADD CONSTRAINT `fk_search_logs_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_search_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Ограничения внешнего ключа таблицы `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `specifications`
--
ALTER TABLE `specifications`
  ADD CONSTRAINT `fk_spec_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Ограничения внешнего ключа таблицы `specification_items`
--
ALTER TABLE `specification_items`
  ADD CONSTRAINT `fk_si_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `fk_si_spec` FOREIGN KEY (`specification_id`) REFERENCES `specifications` (`specification_id`);

--
-- Ограничения внешнего ключа таблицы `stock_balances`
--
ALTER TABLE `stock_balances`
  ADD CONSTRAINT `stock_balances_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `stock_balances_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`);

--
-- Ограничения внешнего ключа таблицы `stock_change_log`
--
ALTER TABLE `stock_change_log`
  ADD CONSTRAINT `fk_scl_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `stock_history`
--
ALTER TABLE `stock_history`
  ADD CONSTRAINT `stock_history_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `stock_history_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`);

--
-- Ограничения внешнего ключа таблицы `supplier_mappings`
--
ALTER TABLE `supplier_mappings`
  ADD CONSTRAINT `supplier_mappings_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Ограничения внешнего ключа таблицы `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`);

--
-- Ограничения внешнего ключа таблицы `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Ограничения внешнего ключа таблицы `warehouses`
--
ALTER TABLE `warehouses`
  ADD CONSTRAINT `fk_warehouses_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`city_id`) ON DELETE SET NULL;

--
-- Ограничения внешнего ключа таблицы `warehouse_delivery_dates`
--
ALTER TABLE `warehouse_delivery_dates`
  ADD CONSTRAINT `fk_wddate_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `delivery_schedules` (`schedule_id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `warehouse_delivery_days`
--
ALTER TABLE `warehouse_delivery_days`
  ADD CONSTRAINT `fk_wdd_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `delivery_schedules` (`schedule_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
