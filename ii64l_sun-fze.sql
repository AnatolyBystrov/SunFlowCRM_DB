-- phpMyAdmin SQL Dump
-- version 4.9.6
-- https://www.phpmyadmin.net/
--
-- Хост: ii64l.myd.infomaniak.com
-- Время создания: Фев 06 2026 г., 10:28
-- Версия сервера: 10.4.17-MariaDB-1:10.4.17+maria~jessie-log
-- Версия PHP: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `ii64l_sun-fze`
--

-- --------------------------------------------------------

--
-- Структура таблицы `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `action` enum('created','updated','deleted') COLLATE utf8_unicode_ci NOT NULL,
  `log_type` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `log_type_title` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `log_type_id` int(11) NOT NULL DEFAULT 0,
  `changes` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_for` varchar(30) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  `log_for_id` int(11) NOT NULL DEFAULT 0,
  `log_for2` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_for_id2` int(11) DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `created_by` int(11) NOT NULL,
  `share_with` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `files` text COLLATE utf8_unicode_ci NOT NULL,
  `read_by` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `attendance`
--

CREATE TABLE `attendance` (
  `id` int(11) NOT NULL,
  `status` enum('incomplete','pending','approved','rejected','deleted') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'incomplete',
  `user_id` int(11) NOT NULL,
  `in_time` datetime NOT NULL,
  `out_time` datetime DEFAULT NULL,
  `checked_by` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `checked_at` datetime DEFAULT NULL,
  `reject_reason` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `brokering_projects`
--

CREATE TABLE `brokering_projects` (
  `id` int(11) NOT NULL,
  `starred_by` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `estimate_id` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT 0,
  `created_date` date DEFAULT NULL,
  `title` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `outward_num` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `reinsurer_count` int(11) NOT NULL,
  `client_id` int(11) DEFAULT NULL,
  `thread` text CHARACTER SET utf8 DEFAULT NULL,
  `inward_date` date DEFAULT NULL,
  `outward_date` date DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `line_of_business` int(11) DEFAULT NULL,
  `class_of_business` int(11) DEFAULT NULL,
  `original_insured_id` int(11) DEFAULT NULL,
  `Insured_Insurer_id` int(11) DEFAULT NULL,
  `co_broker_inward_id` int(11) DEFAULT NULL,
  `reinsured_id` int(11) DEFAULT NULL,
  `co_broker_outward_id` int(11) DEFAULT NULL,
  `reinsurer_id` int(11) DEFAULT NULL,
  `type_of_business` enum('Facultative','Treaty') COLLATE utf8_unicode_ci DEFAULT NULL,
  `proportional` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `region` text CHARACTER SET utf8 DEFAULT NULL,
  `country` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `ccy` int(11) DEFAULT NULL,
  `fx_rate` double DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `period` int(3) DEFAULT NULL,
  `limit_or_sum_insured` double DEFAULT 0,
  `share` double DEFAULT 0,
  `liability_c_c` double DEFAULT 0,
  `gross_prem_share_c_c` double DEFAULT 0,
  `glinso_brokerare_per` double DEFAULT 0,
  `glinso_brokerare_c_c` double DEFAULT 0,
  `net_prem_reinsurer_c_c` double DEFAULT 0,
  `fronting_fee_c_c` double DEFAULT 0,
  `gross_prem_usd` double DEFAULT 0,
  `glinso_brokerare_usd` double DEFAULT 0,
  `net_prem_reinsurer_usd` double DEFAULT 0,
  `fronting_fee_usd` double DEFAULT 0,
  `manager` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `cn_check` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `ps_check` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `paid_per` double DEFAULT 0,
  `paid_c_c_glinso_brokerage` double DEFAULT 0,
  `notes` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice` text CHARACTER SET utf8 DEFAULT NULL,
  `status` enum('open','completed','hold','canceled','changes, closed') COLLATE utf8_unicode_ci DEFAULT 'open',
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `chat`
--

CREATE TABLE `chat` (
  `id` int(11) NOT NULL,
  `sender` int(11) NOT NULL,
  `message` text NOT NULL,
  `time_` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `file` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `checklist_items`
--

CREATE TABLE `checklist_items` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `is_checked` int(11) NOT NULL DEFAULT 0,
  `task_id` int(11) NOT NULL DEFAULT 0,
  `sort` int(11) NOT NULL DEFAULT 0,
  `deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `ci_sessions`
--

CREATE TABLE `ci_sessions` (
  `id` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `data` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `class_of_business`
--

CREATE TABLE `class_of_business` (
  `id` int(11) NOT NULL,
  `line_code` varchar(3) NOT NULL DEFAULT '',
  `line_name` varchar(200) NOT NULL DEFAULT '',
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `company_name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `client_idenity` set('Insured','Agency','Reinsured','Broker','Reinsurer','Other') COLLATE utf8_unicode_ci DEFAULT NULL,
  `client_type` enum('legal person','private person') COLLATE utf8_unicode_ci NOT NULL,
  `address` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_date` date DEFAULT NULL,
  `website` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `currency_symbol` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `starred_by` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `group_ids` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT 0,
  `is_lead` tinyint(1) DEFAULT 0,
  `lead_status_id` int(11) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `sort` int(11) DEFAULT 0,
  `lead_source_id` int(11) DEFAULT NULL,
  `last_lead_status` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `client_migration_date` date DEFAULT '0001-01-01',
  `vat_number` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `currency` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
  `disable_online_payment` tinyint(1) DEFAULT 0,
  `short_company_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type_of_incorporation` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `native_language_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_date` date DEFAULT '0001-01-01',
  `registration_number` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_authority` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tin` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `regulated_activity` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `license_number` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `license_issuance_date` date DEFAULT '0001-01-01',
  `license_expiry_date` date DEFAULT '0001-01-01',
  `license_expiry_indefinitely` tinyint(1) NOT NULL DEFAULT 0,
  `licensing_authority` varchar(150) COLLATE utf8_unicode_ci DEFAULT NULL,
  `licensing_activity` varchar(350) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_office` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `postal_address` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `have_branches` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `branches_addresses` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `bank_details` varchar(450) COLLATE utf8_unicode_ci DEFAULT NULL,
  `source_of_income` varchar(300) COLLATE utf8_unicode_ci DEFAULT NULL,
  `limitations` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `limitations_info` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `sanctions` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `sanctions_info` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `foreign_tax_residency` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `foreign_tax_countries` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fax` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `base_currency` int(5) DEFAULT NULL,
  `paid_up_capital` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `financial_activities` enum('Profit company','Non-profit company') COLLATE utf8_unicode_ci DEFAULT NULL,
  `executive_officers` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `five_per_shareholders` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `international_rating` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_rating` int(11) DEFAULT NULL,
  `recommendations` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `ultimate_beneficial_owner` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  `client_status_id` int(11) DEFAULT 4,
  `review_date` date DEFAULT NULL,
  `availability_pep` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `information_pep` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `business_activity` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `former_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `client_comments`
--

CREATE TABLE `client_comments` (
  `id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `client_id` int(11) NOT NULL DEFAULT 0,
  `files` longtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `client_groups`
--

CREATE TABLE `client_groups` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `client_sellers`
--

CREATE TABLE `client_sellers` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `percent` double NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `client_status`
--

CREATE TABLE `client_status` (
  `id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `color` varchar(7) COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `companies`
--

CREATE TABLE `companies` (
  `id` int(11) NOT NULL,
  `company_name` varchar(64) NOT NULL,
  `email` varchar(64) NOT NULL,
  `address` text NOT NULL,
  `phone` varchar(16) DEFAULT NULL,
  `reminders` enum('On','Off') NOT NULL DEFAULT 'On'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `compliance_list_test`
--

CREATE TABLE `compliance_list_test` (
  `id` int(11) NOT NULL COMMENT 'skip',
  `global_status` int(11) NOT NULL COMMENT 'skip 1-проверен, 2-корзина',
  `from_razdel` varchar(100) NOT NULL COMMENT 'skip',
  `current_risk_rate` varchar(20) NOT NULL COMMENT 'skip',
  `changes` text NOT NULL COMMENT 'skip',
  `compliance_comments` text NOT NULL COMMENT 'Комментарии',
  `compliance_status` int(11) NOT NULL COMMENT 'skip',
  `country_code` varchar(10) NOT NULL COMMENT 'Код страны',
  `client_type` varchar(30) NOT NULL COMMENT 'Тип клиента',
  `client_status` varchar(250) NOT NULL COMMENT 'Предполагаемый статус клиента',
  `other_status` varchar(100) NOT NULL COMMENT 'Уточнить статусклиента',
  `full_name` varchar(250) NOT NULL COMMENT 'ФИО',
  `full_name_f` varchar(50) NOT NULL COMMENT 'Фамилия',
  `full_name_i` varchar(50) NOT NULL COMMENT 'Имя',
  `full_name_o` varchar(50) NOT NULL COMMENT 'Отчество',
  `birth_date` varchar(15) NOT NULL COMMENT 'Дата рождения',
  `birth_place` varchar(100) NOT NULL COMMENT 'Место рождения клиента',
  `citizen_of_russia` varchar(11) NOT NULL COMMENT 'Гражданин РФ?',
  `is_ip` varchar(11) NOT NULL COMMENT 'Клиент -индивидуальный предприниматель?',
  `nationality` varchar(100) NOT NULL COMMENT 'Гражданство',
  `residence_permit` varchar(11) NOT NULL COMMENT 'Имеется ли разрешениена проживание в РФ?',
  `type_of_incorporation` varchar(100) NOT NULL COMMENT 'Организационно-правовая форма',
  `full_company_name` varchar(250) NOT NULL COMMENT 'Полное наименование',
  `short_company_name` varchar(250) NOT NULL COMMENT 'Сокращённое наименование',
  `native_language_name` varchar(50) NOT NULL COMMENT 'Наименование на иностранном языке',
  `domiciled_in_russia` varchar(11) NOT NULL COMMENT 'Резидент РФ?',
  `headquarters_jusridicstion` varchar(250) NOT NULL COMMENT 'Юрисдикция (страна регистрации)',
  `passport_ser` varchar(10) NOT NULL,
  `passport_number` varchar(20) NOT NULL COMMENT 'Серия и номер паспорта',
  `passport_issuance_date` varchar(15) NOT NULL COMMENT 'Дата выдачи паспорта',
  `passport_expiry_date` varchar(15) NOT NULL COMMENT 'Срок действия паспорта',
  `passport_issuing` varchar(250) NOT NULL COMMENT 'Орган выдачи паспорта',
  `passport_code` varchar(20) NOT NULL COMMENT 'Код подразделения',
  `migration_card_number` varchar(20) NOT NULL COMMENT 'Номер миграционной карты',
  `migration_card_issuance_date` varchar(15) NOT NULL COMMENT 'Дата выдачи миграционной карты',
  `migration_card_expiry_date` varchar(15) NOT NULL COMMENT 'Дата окончания срока пребывания',
  `registration_date` varchar(20) NOT NULL COMMENT 'Дата регистрации',
  `registration_number` varchar(100) NOT NULL COMMENT 'Регистрационный номер (ОГРН / ОГРНИП)',
  `registration_authority` varchar(250) NOT NULL COMMENT 'Регистрирующий орган',
  `tin` varchar(20) NOT NULL COMMENT 'Налоговый номер (ИНН)',
  `snils` varchar(20) NOT NULL COMMENT 'Страховой номер(СНИЛС)',
  `tiea` varchar(20) NOT NULL COMMENT 'Имеется ли у клиента соглашение об избежании двойного налогообложения с Россией?',
  `certificate_of_tax_residency` varchar(20) NOT NULL COMMENT 'Имеется ли справка, подтверждающая, что клиент имеет постоянное местонахождение в государстве, с которым Россия имеет международный договор?',
  `kpp` varchar(20) NOT NULL COMMENT 'КПП',
  `okved` varchar(200) NOT NULL COMMENT 'ОКВЭД',
  `okato` varchar(200) NOT NULL COMMENT 'ОКАТО',
  `regulated_activity` varchar(11) NOT NULL COMMENT 'Осуществляется ли лицензируемая деятельность?',
  `license_number` varchar(50) NOT NULL COMMENT 'Номер лицензии',
  `license_issuance_date` varchar(50) NOT NULL COMMENT 'Дата выдачи лицензии',
  `license_expiry_date` varchar(20) NOT NULL COMMENT 'Срок действия лицензии',
  `licensing_authority` varchar(250) NOT NULL COMMENT 'Орган, выдавший лицензию',
  `licensing_activity` text NOT NULL COMMENT 'Перечень видов лицензируемой деятельности',
  `Regulated activity` text NOT NULL COMMENT 'Лицензируемая деятельность',
  `telephone` varchar(50) NOT NULL COMMENT 'Телефон',
  `fax` varchar(50) NOT NULL COMMENT 'Факс',
  `email` varchar(100) NOT NULL COMMENT 'Электронная почта',
  `website` varchar(100) NOT NULL COMMENT 'Сайт',
  `social_networks` varchar(200) NOT NULL COMMENT 'Социальные сети',
  `address` text NOT NULL COMMENT 'Адрес',
  `address_ind` varchar(10) NOT NULL COMMENT 'Индекс',
  `address_country` varchar(50) NOT NULL COMMENT 'Страна',
  `address_resp` varchar(100) NOT NULL COMMENT 'Республика',
  `address_city` varchar(100) NOT NULL COMMENT 'Город',
  `address_region` varchar(100) NOT NULL COMMENT 'Район',
  `address_street` varchar(100) NOT NULL COMMENT 'Улица',
  `address_dom` varchar(10) NOT NULL COMMENT 'Дом',
  `address_korp` varchar(10) NOT NULL COMMENT 'Корпус',
  `address_str` varchar(10) NOT NULL COMMENT 'Строение',
  `address_kv` varchar(10) NOT NULL COMMENT 'Квартира',
  `address_of` varchar(10) NOT NULL COMMENT 'Офис',
  `is_live` varchar(11) NOT NULL COMMENT 'Клиент проживает поданному адресу?',
  `is_office` varchar(11) NOT NULL COMMENT 'Действующий офис компании расположен по данному адресу?',
  `postal_address` text NOT NULL COMMENT 'Адрес фактического ведения бизнеса или проживания (почтовый)',
  `postal_address_ind` varchar(10) NOT NULL COMMENT 'Индекс',
  `postal_address_country` varchar(50) NOT NULL COMMENT 'Страна',
  `postal_address_resp` varchar(100) NOT NULL COMMENT 'Республика',
  `postal_address_city` varchar(100) NOT NULL COMMENT 'Город',
  `postal_address_region` varchar(100) NOT NULL COMMENT 'Район',
  `postal_address_street` varchar(100) NOT NULL COMMENT 'Улица',
  `postal_address_dom` varchar(10) NOT NULL COMMENT 'Дом',
  `postal_address_korp` varchar(10) NOT NULL COMMENT 'Корпус',
  `postal_address_str` varchar(10) NOT NULL COMMENT 'Строение',
  `postal_address_kv` varchar(10) NOT NULL COMMENT 'Квартира',
  `postal_address_of` varchar(10) NOT NULL COMMENT 'Офис',
  `have_branches` varchar(11) NOT NULL COMMENT 'Имеются ли филиалы и представительства в других регионах?',
  `branches_addresses` text NOT NULL COMMENT 'Указать адресафилиалов ипредставительств',
  `current_account` varchar(100) NOT NULL COMMENT 'Расчётный счёт',
  `bank_name` varchar(250) NOT NULL COMMENT 'Наименование банка',
  `swift_code` varchar(50) NOT NULL COMMENT 'БИК',
  `correspondent_account` varchar(50) NOT NULL COMMENT 'Корреспондентский счёт',
  `politically_exposed_person` varchar(11) NOT NULL COMMENT 'Клиент - публичноедолжностное лицо?',
  `current_position` varchar(250) NOT NULL COMMENT 'Занимаемая должность',
  `employer_name` text NOT NULL COMMENT 'Наименование работодателя',
  `employer_address` text NOT NULL COMMENT 'Адрес работодателя',
  `source_of_income` varchar(250) NOT NULL COMMENT 'Источник дохода',
  `family_connected_to_politic` varchar(11) NOT NULL COMMENT 'Клиент - родственникпубличногодолжностного лица?',
  `relation_degree` varchar(50) NOT NULL COMMENT 'Степень родства',
  `behalf_company` varchar(11) NOT NULL COMMENT 'Клиент - сотрудникюридического лица?',
  `behalf_company_name` varchar(250) NOT NULL COMMENT 'От имени какойкомпании действуетклиент?',
  `position_in_the_company` text NOT NULL COMMENT 'Указать должность и основание для подписи или номер и дату доверенности',
  `limitations` varchar(50) NOT NULL COMMENT 'Имеются ли введенные ограничения на ведение деятельности?',
  `limitations_info` text NOT NULL COMMENT 'Сведения обограничениях',
  `sanctions` varchar(11) NOT NULL COMMENT 'Присутствует ли Клиент в санкционных списках каких-либо стран и международных организаций?',
  `sanctions_info` text NOT NULL COMMENT 'Сведения о санкциях',
  `foreign_tax_residency` varchar(10) NOT NULL COMMENT 'Налоговое резиденство в иностранных государствах',
  `foreign_tax_countries` text NOT NULL COMMENT 'Укажите все страны, налоговым резидентом которых является контрAgency',
  `base_currency` varchar(20) NOT NULL COMMENT 'Валюта уставного капитала',
  `paid_up_capital` varchar(50) NOT NULL COMMENT 'Размер уставногокапитала',
  `financial_activities` text NOT NULL COMMENT 'Цели финансово-хозяйственнойдеятельности',
  `executive_officers` text NOT NULL COMMENT 'Структура иперсональный составорганов управления',
  `five_per_shareholders` text NOT NULL COMMENT 'Акционеры (участники)с долей более 5%',
  `ultimate_beneficial_owner` varchar(250) NOT NULL COMMENT 'Конечный бенефициар,влияющий на решениякомпании',
  `international_rating` varchar(250) NOT NULL COMMENT 'Рейтинг компании',
  `is_rating` int(11) NOT NULL,
  `expected_business` text NOT NULL,
  `other_insurance` text NOT NULL COMMENT 'С какими страховыми и перестраховочными компаниями доводилось работать?',
  `recommendations` text NOT NULL COMMENT 'Сведения орекомендациях ипоручителях',
  `current_portfolio` text NOT NULL COMMENT 'Текущий портфельAgencyа',
  `user_id` int(11) NOT NULL COMMENT 'skip',
  `edit_user_id` int(11) NOT NULL,
  `date_create` date NOT NULL COMMENT 'skip',
  `data_valid_till` date NOT NULL,
  `on_1_work` int(11) NOT NULL COMMENT 'skip',
  `work_agent_id` int(11) NOT NULL COMMENT 'skip',
  `on_dfm_work` int(11) NOT NULL COMMENT 'skip',
  `dfm_work_agent_id` int(11) NOT NULL COMMENT 'skip',
  `dfm_id` int(11) NOT NULL COMMENT 'skip'
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `countries_list`
--

CREATE TABLE `countries_list` (
  `id` int(11) NOT NULL,
  `country_code` varchar(2) NOT NULL DEFAULT '',
  `country_name` varchar(100) NOT NULL DEFAULT '',
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `currency_list`
--

CREATE TABLE `currency_list` (
  `id` int(11) NOT NULL,
  `code` varchar(10) NOT NULL,
  `title` varchar(100) NOT NULL,
  `code_title` varchar(100) NOT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `custom_fields`
--

CREATE TABLE `custom_fields` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `placeholder` text COLLATE utf8_unicode_ci NOT NULL,
  `example_variable_name` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `options` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `field_type` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `related_to` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 0,
  `show_in_table` tinyint(1) NOT NULL DEFAULT 0,
  `show_in_invoice` tinyint(1) NOT NULL DEFAULT 0,
  `show_in_estimate` tinyint(1) NOT NULL DEFAULT 0,
  `visible_to_admins_only` tinyint(1) NOT NULL DEFAULT 0,
  `hide_from_clients` tinyint(1) NOT NULL DEFAULT 0,
  `disable_editing_by_clients` tinyint(1) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `custom_field_values`
--

CREATE TABLE `custom_field_values` (
  `id` int(11) NOT NULL,
  `related_to_type` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `related_to_id` int(11) NOT NULL,
  `custom_field_id` int(11) NOT NULL,
  `value` longtext COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `custom_widgets`
--

CREATE TABLE `custom_widgets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `show_title` tinyint(1) NOT NULL DEFAULT 0,
  `show_border` tinyint(1) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `dashboards`
--

CREATE TABLE `dashboards` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `data` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `color` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `departmentmembers`
--

CREATE TABLE `departmentmembers` (
  `id` int(11) NOT NULL,
  `department` int(11) NOT NULL,
  `member` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `departments`
--

CREATE TABLE `departments` (
  `id` int(11) NOT NULL,
  `company` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `email` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `email_templates`
--

CREATE TABLE `email_templates` (
  `id` int(11) NOT NULL,
  `template_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `email_subject` text COLLATE utf8_unicode_ci NOT NULL,
  `default_message` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `custom_message` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `estimates`
--

CREATE TABLE `estimates` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `estimate_request_id` int(11) NOT NULL DEFAULT 0,
  `estimate_date` date NOT NULL,
  `valid_until` date NOT NULL,
  `note` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_email_sent_date` date DEFAULT NULL,
  `status` enum('draft','sent','accepted','declined') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'draft',
  `tax_id` int(11) NOT NULL DEFAULT 0,
  `tax_id2` int(11) NOT NULL DEFAULT 0,
  `discount_type` enum('before_tax','after_tax') COLLATE utf8_unicode_ci NOT NULL,
  `discount_amount` double NOT NULL,
  `discount_amount_type` enum('percentage','fixed_amount') COLLATE utf8_unicode_ci NOT NULL,
  `project_id` int(11) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `estimate_forms`
--

CREATE TABLE `estimate_forms` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8_unicode_ci NOT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL,
  `assigned_to` int(11) NOT NULL,
  `public` tinyint(1) NOT NULL DEFAULT 0,
  `enable_attachment` tinyint(4) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `estimate_items`
--

CREATE TABLE `estimate_items` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` double NOT NULL,
  `unit_type` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `rate` double NOT NULL,
  `total` double NOT NULL,
  `sort` int(11) NOT NULL DEFAULT 0,
  `estimate_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `estimate_requests`
--

CREATE TABLE `estimate_requests` (
  `id` int(11) NOT NULL,
  `estimate_form_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `client_id` int(11) NOT NULL,
  `lead_id` int(11) NOT NULL,
  `assigned_to` int(11) NOT NULL,
  `status` enum('new','processing','hold','canceled','estimated') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'new',
  `files` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `events`
--

CREATE TABLE `events` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `location` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `client_id` int(11) NOT NULL DEFAULT 0,
  `labels` text COLLATE utf8_unicode_ci NOT NULL,
  `share_with` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `editable_google_event` tinyint(1) NOT NULL DEFAULT 0,
  `google_event_id` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0,
  `color` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `recurring` int(1) NOT NULL DEFAULT 0,
  `repeat_every` int(11) NOT NULL DEFAULT 0,
  `repeat_type` enum('days','weeks','months','years') COLLATE utf8_unicode_ci DEFAULT NULL,
  `no_of_cycles` int(11) NOT NULL DEFAULT 0,
  `last_start_date` date DEFAULT NULL,
  `recurring_dates` longtext COLLATE utf8_unicode_ci NOT NULL,
  `confirmed_by` text COLLATE utf8_unicode_ci NOT NULL,
  `rejected_by` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `expenses`
--

CREATE TABLE `expenses` (
  `id` int(11) NOT NULL,
  `expense_date` date NOT NULL,
  `type_project` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount` double NOT NULL,
  `amount_ccy` double NOT NULL,
  `reinsurer_id` int(11) NOT NULL,
  `files` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `project_id` int(11) NOT NULL DEFAULT 0,
  `ccy` int(11) NOT NULL,
  `user_id` int(11) DEFAULT 0,
  `id_stage` int(11) NOT NULL DEFAULT 1,
  `tax_id2` int(11) NOT NULL DEFAULT 0,
  `category_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `expenses_stage`
--

CREATE TABLE `expenses_stage` (
  `id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `key_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `color` varchar(7) COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `fields`
--

CREATE TABLE `fields` (
  `id` int(11) NOT NULL,
  `company` int(11) NOT NULL,
  `user` int(11) NOT NULL,
  `label` text NOT NULL,
  `value` text NOT NULL,
  `type` enum('custom','input','stamp') NOT NULL DEFAULT 'custom'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `files`
--

CREATE TABLE `files` (
  `id` int(11) NOT NULL,
  `company` int(11) NOT NULL,
  `folder` int(11) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `uploaded_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `name` varchar(256) NOT NULL,
  `filename` varchar(256) NOT NULL,
  `extension` varchar(16) NOT NULL DEFAULT 'pdf',
  `size` int(11) NOT NULL DEFAULT 0,
  `document_key` varchar(32) NOT NULL,
  `status` enum('Unsigned','Signed') NOT NULL DEFAULT 'Unsigned',
  `editted` enum('Yes','No') NOT NULL DEFAULT 'No',
  `is_template` enum('No','Yes') NOT NULL DEFAULT 'No',
  `template_fields` text DEFAULT NULL,
  `sign_reason` text DEFAULT NULL,
  `accessibility` enum('Everyone','Departments','Only Me') NOT NULL DEFAULT 'Everyone',
  `public_permissions` enum('read_only','sign_edit','disabled') NOT NULL DEFAULT 'sign_edit',
  `departments` varchar(256) DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `folders`
--

CREATE TABLE `folders` (
  `id` int(11) NOT NULL,
  `company` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `name` varchar(256) NOT NULL,
  `folder` int(11) NOT NULL DEFAULT 1,
  `accessibility` enum('Everyone','Departments','Only Me') NOT NULL DEFAULT 'Everyone',
  `departments` varchar(256) DEFAULT NULL,
  `password` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `general_files`
--

CREATE TABLE `general_files` (
  `id` int(11) NOT NULL,
  `file_name` text COLLATE utf8_unicode_ci NOT NULL,
  `file_id` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `service_type` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_size` double NOT NULL,
  `created_at` datetime NOT NULL,
  `client_id` int(11) NOT NULL DEFAULT 0,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `uploaded_by` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `help_articles`
--

CREATE TABLE `help_articles` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8_unicode_ci NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'active',
  `files` text COLLATE utf8_unicode_ci NOT NULL,
  `total_views` int(11) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `help_categories`
--

CREATE TABLE `help_categories` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `type` enum('help','knowledge_base') COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'active',
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `historical_rate`
--

CREATE TABLE `historical_rate` (
  `id` int(11) NOT NULL,
  `dt` date NOT NULL,
  `EUR` double NOT NULL DEFAULT 0,
  `GBP` double NOT NULL DEFAULT 0,
  `INR` double NOT NULL DEFAULT 0,
  `AUD` double NOT NULL DEFAULT 0,
  `CAD` double NOT NULL DEFAULT 0,
  `SGD` double NOT NULL DEFAULT 0,
  `CHF` double NOT NULL DEFAULT 0,
  `MYR` double NOT NULL DEFAULT 0,
  `JPY` double NOT NULL DEFAULT 0,
  `CNY` double NOT NULL DEFAULT 0,
  `NZD` double NOT NULL DEFAULT 0,
  `THB` double NOT NULL DEFAULT 0,
  `HUF` double NOT NULL DEFAULT 0,
  `AED` double NOT NULL DEFAULT 0,
  `HKD` double NOT NULL DEFAULT 0,
  `MXN` double NOT NULL DEFAULT 0,
  `ZAR` double NOT NULL DEFAULT 0,
  `PHP` double NOT NULL DEFAULT 0,
  `SEK` double NOT NULL DEFAULT 0,
  `IDR` double NOT NULL DEFAULT 0,
  `SAR` double NOT NULL DEFAULT 0,
  `BRL` double NOT NULL DEFAULT 0,
  `TRY` double NOT NULL DEFAULT 0,
  `KES` double NOT NULL DEFAULT 0,
  `KRW` double NOT NULL DEFAULT 0,
  `EGP` double NOT NULL DEFAULT 0,
  `IQD` double NOT NULL DEFAULT 0,
  `NOK` double NOT NULL DEFAULT 0,
  `KWD` double NOT NULL DEFAULT 0,
  `RUB` double NOT NULL DEFAULT 0,
  `DKK` double NOT NULL DEFAULT 0,
  `PKR` double NOT NULL DEFAULT 0,
  `ILS` double NOT NULL DEFAULT 0,
  `PLN` double NOT NULL DEFAULT 0,
  `QAR` double NOT NULL DEFAULT 0,
  `XAU` double NOT NULL DEFAULT 0,
  `OMR` double NOT NULL DEFAULT 0,
  `COP` double NOT NULL DEFAULT 0,
  `CLP` double NOT NULL DEFAULT 0,
  `TWD` double NOT NULL DEFAULT 0,
  `ARS` double NOT NULL DEFAULT 0,
  `CZK` double NOT NULL DEFAULT 0,
  `VND` double NOT NULL DEFAULT 0,
  `MAD` double NOT NULL DEFAULT 0,
  `JOD` double NOT NULL DEFAULT 0,
  `BHD` double NOT NULL DEFAULT 0,
  `XOF` double NOT NULL DEFAULT 0,
  `LKR` double NOT NULL DEFAULT 0,
  `UAH` double NOT NULL DEFAULT 0,
  `NGN` double NOT NULL DEFAULT 0,
  `TND` double NOT NULL DEFAULT 0,
  `UGX` double NOT NULL DEFAULT 0,
  `RON` double NOT NULL DEFAULT 0,
  `BDT` double NOT NULL DEFAULT 0,
  `PEN` double NOT NULL DEFAULT 0,
  `GEL` double NOT NULL DEFAULT 0,
  `XAF` double NOT NULL DEFAULT 0,
  `FJD` double NOT NULL DEFAULT 0,
  `VEF` double NOT NULL DEFAULT 0,
  `VES` double NOT NULL DEFAULT 0,
  `BYN` double NOT NULL DEFAULT 0,
  `HRK` double NOT NULL DEFAULT 0,
  `UZS` double NOT NULL DEFAULT 0,
  `BGN` double NOT NULL DEFAULT 0,
  `DZD` double NOT NULL DEFAULT 0,
  `IRR` double NOT NULL DEFAULT 0,
  `DOP` double NOT NULL DEFAULT 0,
  `ISK` double NOT NULL DEFAULT 0,
  `XAG` double NOT NULL DEFAULT 0,
  `CRC` double NOT NULL DEFAULT 0,
  `SYP` double NOT NULL DEFAULT 0,
  `LYD` double NOT NULL DEFAULT 0,
  `JMD` double NOT NULL DEFAULT 0,
  `MUR` double NOT NULL DEFAULT 0,
  `GHS` double NOT NULL DEFAULT 0,
  `AOA` double NOT NULL DEFAULT 0,
  `UYU` double NOT NULL DEFAULT 0,
  `AFN` double NOT NULL DEFAULT 0,
  `LBP` double NOT NULL DEFAULT 0,
  `XPF` double NOT NULL DEFAULT 0,
  `TTD` double NOT NULL DEFAULT 0,
  `TZS` double NOT NULL DEFAULT 0,
  `ALL` double NOT NULL DEFAULT 0,
  `XCD` double NOT NULL DEFAULT 0,
  `GTQ` double NOT NULL DEFAULT 0,
  `NPR` double NOT NULL DEFAULT 0,
  `BOB` double NOT NULL DEFAULT 0,
  `ZWD` double NOT NULL DEFAULT 0,
  `BBD` double NOT NULL DEFAULT 0,
  `CUC` double NOT NULL DEFAULT 0,
  `LAK` double NOT NULL DEFAULT 0,
  `BND` double NOT NULL DEFAULT 0,
  `BWP` double NOT NULL DEFAULT 0,
  `HNL` double NOT NULL DEFAULT 0,
  `PYG` double NOT NULL DEFAULT 0,
  `ETB` double NOT NULL DEFAULT 0,
  `NAD` double NOT NULL DEFAULT 0,
  `PGK` double NOT NULL DEFAULT 0,
  `SDG` double NOT NULL DEFAULT 0,
  `MOP` double NOT NULL DEFAULT 0,
  `NIO` double NOT NULL DEFAULT 0,
  `BMD` double NOT NULL DEFAULT 0,
  `KZT` double NOT NULL DEFAULT 0,
  `PAB` double NOT NULL DEFAULT 0,
  `BAM` double NOT NULL DEFAULT 0,
  `GYD` double NOT NULL DEFAULT 0,
  `YER` double NOT NULL DEFAULT 0,
  `MGA` double NOT NULL DEFAULT 0,
  `KYD` double NOT NULL DEFAULT 0,
  `MZN` double NOT NULL DEFAULT 0,
  `RSD` double NOT NULL DEFAULT 0,
  `SCR` double NOT NULL DEFAULT 0,
  `AMD` double NOT NULL DEFAULT 0,
  `SBD` double NOT NULL DEFAULT 0,
  `AZN` double NOT NULL DEFAULT 0,
  `SLL` double NOT NULL DEFAULT 0,
  `TOP` double NOT NULL DEFAULT 0,
  `BZD` double NOT NULL DEFAULT 0,
  `MWK` double NOT NULL DEFAULT 0,
  `GMD` double NOT NULL DEFAULT 0,
  `BIF` double NOT NULL DEFAULT 0,
  `SOS` double NOT NULL DEFAULT 0,
  `HTG` double NOT NULL DEFAULT 0,
  `GNF` double NOT NULL DEFAULT 0,
  `MVR` double NOT NULL DEFAULT 0,
  `MNT` double NOT NULL DEFAULT 0,
  `CDF` double NOT NULL DEFAULT 0,
  `STN` double NOT NULL DEFAULT 0,
  `TJS` double NOT NULL DEFAULT 0,
  `KPW` double NOT NULL DEFAULT 0,
  `MMK` double NOT NULL DEFAULT 0,
  `LSL` double NOT NULL DEFAULT 0,
  `LRD` double NOT NULL DEFAULT 0,
  `KGS` double NOT NULL DEFAULT 0,
  `GIP` double NOT NULL DEFAULT 0,
  `XPT` double NOT NULL DEFAULT 0,
  `MDL` double NOT NULL DEFAULT 0,
  `CUP` double NOT NULL DEFAULT 0,
  `KHR` double NOT NULL DEFAULT 0,
  `MKD` double NOT NULL DEFAULT 0,
  `VUV` double NOT NULL DEFAULT 0,
  `MRU` double NOT NULL DEFAULT 0,
  `ANG` double NOT NULL DEFAULT 0,
  `SZL` double NOT NULL DEFAULT 0,
  `CVE` double NOT NULL DEFAULT 0,
  `SRD` double NOT NULL DEFAULT 0,
  `XPD` double NOT NULL DEFAULT 0,
  `SVC` double NOT NULL DEFAULT 0,
  `BSD` double NOT NULL DEFAULT 0,
  `XDR` double NOT NULL DEFAULT 0,
  `RWF` double NOT NULL DEFAULT 0,
  `AWG` double NOT NULL DEFAULT 0,
  `DJF` double NOT NULL DEFAULT 0,
  `BTN` double NOT NULL DEFAULT 0,
  `KMF` double NOT NULL DEFAULT 0,
  `WST` double NOT NULL DEFAULT 0,
  `SPL` double NOT NULL DEFAULT 0,
  `ERN` double NOT NULL DEFAULT 0,
  `FKP` double NOT NULL DEFAULT 0,
  `SHP` double NOT NULL DEFAULT 0,
  `JEP` double NOT NULL DEFAULT 0,
  `TMT` double NOT NULL DEFAULT 0,
  `TVD` double NOT NULL DEFAULT 0,
  `IMP` double NOT NULL DEFAULT 0,
  `USD` double NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

-- --------------------------------------------------------

--
-- Структура таблицы `history`
--

CREATE TABLE `history` (
  `id` int(11) NOT NULL,
  `company` int(11) NOT NULL,
  `file` varchar(32) NOT NULL,
  `activity` text NOT NULL,
  `time_` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `type` enum('default','success','danger') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `insured_list`
--

CREATE TABLE `insured_list` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `invoices`
--

CREATE TABLE `invoices` (
  `id` int(11) NOT NULL,
  `number_inv` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `client_id` int(11) NOT NULL,
  `type_project` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `project_id` int(11) NOT NULL DEFAULT 0,
  `brok_project_id` int(11) NOT NULL,
  `bill_date` date NOT NULL,
  `due_date` date NOT NULL,
  `note` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_email_sent_date` date DEFAULT NULL,
  `status` enum('draft','not_paid','cancelled') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'draft',
  `tax_id` int(11) NOT NULL DEFAULT 0,
  `tax_id2` int(11) NOT NULL DEFAULT 0,
  `tax_id3` int(11) NOT NULL DEFAULT 0,
  `recurring` tinyint(4) NOT NULL DEFAULT 0,
  `recurring_invoice_id` int(11) NOT NULL DEFAULT 0,
  `repeat_every` int(11) NOT NULL DEFAULT 0,
  `repeat_type` enum('days','weeks','months','years') COLLATE utf8_unicode_ci DEFAULT NULL,
  `no_of_cycles` int(11) NOT NULL DEFAULT 0,
  `next_recurring_date` date DEFAULT NULL,
  `no_of_cycles_completed` int(11) NOT NULL DEFAULT 0,
  `due_reminder_date` date NOT NULL,
  `recurring_reminder_date` date NOT NULL,
  `discount_amount` double NOT NULL,
  `discount_amount_type` enum('percentage','fixed_amount') COLLATE utf8_unicode_ci NOT NULL,
  `discount_type` enum('before_tax','after_tax') COLLATE utf8_unicode_ci NOT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `invoice_credit_notes`
--

CREATE TABLE `invoice_credit_notes` (
  `id` int(11) NOT NULL,
  `number_cn` varchar(4) COLLATE utf8_unicode_ci NOT NULL,
  `amount` double NOT NULL,
  `payment_date` date NOT NULL,
  `note` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0,
  `transaction_id` tinytext COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT 1,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `invoice_items`
--

CREATE TABLE `invoice_items` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` double NOT NULL DEFAULT 1,
  `unit_type` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '1',
  `rate` double NOT NULL,
  `total` double NOT NULL,
  `sort` int(11) NOT NULL DEFAULT 0,
  `invoice_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `invoice_payments`
--

CREATE TABLE `invoice_payments` (
  `id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `payment_num` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `payment_date` date NOT NULL,
  `gross_amount_c` double NOT NULL,
  `our_brok_paid_c` double NOT NULL,
  `ccy` int(11) NOT NULL,
  `fx_rate` double NOT NULL,
  `сommission_bank` double NOT NULL,
  `gross_amount_usd` double NOT NULL,
  `our_brok_paid_usd` double NOT NULL,
  `amount` double NOT NULL,
  `payment_method_id` int(11) NOT NULL,
  `note` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0,
  `transaction_id` tinytext COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT 1,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `invoice_scheduled_payments`
--

CREATE TABLE `invoice_scheduled_payments` (
  `id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT 1,
  `invoice_id` int(11) NOT NULL,
  `reinsurer_id` int(11) NOT NULL,
  `payment_date` date DEFAULT NULL,
  `scheduled_payment_date` date NOT NULL,
  `ccy` int(11) NOT NULL,
  `fx_rate` double NOT NULL DEFAULT 0,
  `amount` double NOT NULL,
  `note` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `id_stage` int(11) DEFAULT 1,
  `status` enum('not_paid','paid') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'not_paid',
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `unit_type` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `rate` double NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `leads`
--

CREATE TABLE `leads` (
  `id` int(11) NOT NULL,
  `company_name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `first_name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `address` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_date` date NOT NULL,
  `website` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `lead_source`
--

CREATE TABLE `lead_source` (
  `id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `lead_status`
--

CREATE TABLE `lead_status` (
  `id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `color` varchar(7) COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `leave_applications`
--

CREATE TABLE `leave_applications` (
  `id` int(11) NOT NULL,
  `leave_type_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_hours` decimal(7,2) NOT NULL,
  `total_days` decimal(5,2) NOT NULL,
  `applicant_id` int(11) NOT NULL,
  `reason` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `status` enum('pending','approved','rejected','canceled') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL,
  `created_by` int(11) NOT NULL,
  `checked_at` datetime DEFAULT NULL,
  `checked_by` int(11) NOT NULL DEFAULT 0,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `leave_types`
--

CREATE TABLE `leave_types` (
  `id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'active',
  `color` varchar(7) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `line_of_business`
--

CREATE TABLE `line_of_business` (
  `id` int(11) NOT NULL,
  `line_code` varchar(3) NOT NULL DEFAULT '',
  `line_name` varchar(100) NOT NULL DEFAULT '',
  `type` varchar(50) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Untitled',
  `message` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `from_user_id` int(11) NOT NULL,
  `to_user_id` int(11) NOT NULL,
  `status` enum('unread','read') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'unread',
  `message_id` int(11) NOT NULL DEFAULT 0,
  `deleted` int(1) NOT NULL DEFAULT 0,
  `files` longtext COLLATE utf8_unicode_ci NOT NULL,
  `deleted_by_users` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `milestones`
--

CREATE TABLE `milestones` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `project_id` int(11) NOT NULL,
  `due_date` date NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `notes`
--

CREATE TABLE `notes` (
  `id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `project_id` int(11) NOT NULL DEFAULT 0,
  `client_id` int(11) NOT NULL DEFAULT 0,
  `user_id` int(11) NOT NULL DEFAULT 0,
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `files` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `description` longtext COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `notify_to` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `read_by` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `event` varchar(250) COLLATE utf8_unicode_ci NOT NULL,
  `project_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `project_comment_id` int(11) NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `ticket_comment_id` int(11) NOT NULL,
  `project_file_id` int(11) NOT NULL,
  `leave_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `to_user_id` int(11) NOT NULL,
  `activity_log_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `lead_id` int(11) NOT NULL,
  `invoice_payment_id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `estimate_id` int(11) NOT NULL,
  `estimate_request_id` int(11) NOT NULL,
  `actual_message_id` int(11) NOT NULL,
  `parent_message_id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `announcement_id` int(11) NOT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `notification_settings`
--

CREATE TABLE `notification_settings` (
  `id` int(11) NOT NULL,
  `event` varchar(250) NOT NULL,
  `category` varchar(50) NOT NULL,
  `enable_email` int(1) NOT NULL DEFAULT 0,
  `enable_web` int(1) NOT NULL DEFAULT 0,
  `notify_to_team` text NOT NULL,
  `notify_to_team_members` text NOT NULL,
  `notify_to_terms` text NOT NULL,
  `sort` int(11) NOT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `pages`
--

CREATE TABLE `pages` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `slug` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'active',
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `payment_methods`
--

CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `type` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'custom',
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `online_payable` tinyint(1) NOT NULL DEFAULT 0,
  `available_on_invoice` tinyint(1) NOT NULL DEFAULT 0,
  `minimum_payment_amount` double NOT NULL DEFAULT 0,
  `settings` longtext COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `paypal_ipn`
--

CREATE TABLE `paypal_ipn` (
  `id` int(11) NOT NULL,
  `transaction_id` tinytext COLLATE utf8_unicode_ci DEFAULT NULL,
  `ipn_hash` longtext COLLATE utf8_unicode_ci NOT NULL,
  `ipn_data` longtext COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `posts`
--

CREATE TABLE `posts` (
  `id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `post_id` int(11) NOT NULL,
  `share_with` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `files` longtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `deadline` date DEFAULT NULL,
  `client_id` int(11) NOT NULL,
  `created_date` date DEFAULT NULL,
  `created_by` int(11) NOT NULL DEFAULT 0,
  `status` enum('open','completed','hold','canceled','changes, closed') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'open',
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` double NOT NULL DEFAULT 0,
  `net_prem_written` double NOT NULL,
  `starred_by` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `estimate_id` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0,
  `ocean_re_inv` enum('Yes','No','ocean_retro','selecta','sunshine','sunshine_selecta') CHARACTER SET utf8 NOT NULL DEFAULT 'No',
  `subdivision_id` int(11) NOT NULL,
  `original_contract_num` text CHARACTER SET utf8 NOT NULL,
  `line_of_business` int(11) NOT NULL,
  `invoice` text CHARACTER SET utf8 NOT NULL,
  `sign_date` date DEFAULT NULL,
  `incep_date` date DEFAULT NULL,
  `comp_date` date DEFAULT NULL,
  `period` int(3) NOT NULL,
  `thread` text CHARACTER SET utf8 NOT NULL,
  `deal` int(4) NOT NULL,
  `source_cont` int(11) NOT NULL,
  `sales_person` int(11) NOT NULL,
  `underwriter` text COLLATE utf8_unicode_ci NOT NULL,
  `reinsured` int(11) NOT NULL,
  `insured` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `location` text COLLATE utf8_unicode_ci NOT NULL,
  `gross_limit` double NOT NULL DEFAULT 0,
  `loss_limit` double NOT NULL DEFAULT 0,
  `our_share` double NOT NULL DEFAULT 0,
  `gross_prem_written` double NOT NULL DEFAULT 0,
  `ccy` int(11) NOT NULL,
  `fx_rate` double NOT NULL,
  `wr_exposure_usd` double NOT NULL DEFAULT 0,
  `gross_prem_written_usd` double NOT NULL DEFAULT 0,
  `total_deductions` double NOT NULL DEFAULT 0,
  `net_prem_written_usd` double NOT NULL DEFAULT 0,
  `prem_schedule` text CHARACTER SET utf8 NOT NULL,
  `paid_premium_usd` double NOT NULL DEFAULT 0,
  `prem_due_ocean_usd` double NOT NULL DEFAULT 0,
  `paid_ocean_usd` double NOT NULL DEFAULT 0,
  `outstanding_prem_ocean_usd` double NOT NULL DEFAULT 0,
  `prem_due_selecta_usd` double NOT NULL DEFAULT 0,
  `paid_to_selecta_usd` double NOT NULL DEFAULT 0,
  `outstanding_prem_to_selecta_usd` double NOT NULL DEFAULT 0,
  `prem_due_to_ewa_usd` double NOT NULL DEFAULT 0,
  `paid_to_ewa_usd` double NOT NULL DEFAULT 0,
  `outstanding_prem_to_ewa_usd` double NOT NULL DEFAULT 0,
  `sun_net_result_usd` double NOT NULL DEFAULT 0,
  `commis_received_sun` double NOT NULL DEFAULT 0,
  `outstanding_commis_due_sun` double NOT NULL DEFAULT 0,
  `object` text CHARACTER SET utf8 NOT NULL,
  `oustanding_loss_usd` double NOT NULL DEFAULT 0,
  `paid_loss_usd` double NOT NULL DEFAULT 0,
  `notes` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `brokerage_deducted` double NOT NULL,
  `net_premium_due_selecta` double NOT NULL,
  `brokerage` tinyint(1) NOT NULL DEFAULT 0,
  `prem_due_sunshine_usd` double NOT NULL,
  `paid_sunshine_usd` double NOT NULL,
  `outstanding_prem_sunshine_usd` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `project_comments`
--

CREATE TABLE `project_comments` (
  `id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `project_id` int(11) NOT NULL DEFAULT 0,
  `comment_id` int(11) NOT NULL DEFAULT 0,
  `task_id` int(11) NOT NULL DEFAULT 0,
  `file_id` int(11) NOT NULL DEFAULT 0,
  `customer_feedback_id` int(11) NOT NULL DEFAULT 0,
  `files` longtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `project_files`
--

CREATE TABLE `project_files` (
  `id` int(11) NOT NULL,
  `file_name` text COLLATE utf8_unicode_ci NOT NULL,
  `file_id` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `service_type` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `file_size` double NOT NULL,
  `created_at` datetime NOT NULL,
  `project_id` int(11) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `project_members`
--

CREATE TABLE `project_members` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `is_leader` tinyint(1) DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `project_settings`
--

CREATE TABLE `project_settings` (
  `project_id` int(11) NOT NULL,
  `setting_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `setting_value` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `project_time`
--

CREATE TABLE `project_time` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `status` enum('open','logged','approved') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'logged',
  `note` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_id` int(11) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `region_list`
--

CREATE TABLE `region_list` (
  `id` int(11) NOT NULL,
  `region_code` varchar(2) NOT NULL DEFAULT '',
  `region_name` varchar(100) NOT NULL DEFAULT '',
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `reinsurer_info`
--

CREATE TABLE `reinsurer_info` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `reinsurer_id` int(11) NOT NULL,
  `company_name` varchar(50) NOT NULL,
  `outward_num` text NOT NULL,
  `outward_date` date NOT NULL,
  `effective_date` date NOT NULL,
  `liability_c_c` double NOT NULL,
  `share` double NOT NULL,
  `net_prem_reinsurer_c_c` double NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `reminders`
--

CREATE TABLE `reminders` (
  `id` int(11) NOT NULL,
  `company` int(11) NOT NULL,
  `subject` varchar(256) NOT NULL,
  `days` int(11) NOT NULL,
  `message` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `requests`
--

CREATE TABLE `requests` (
  `id` int(11) NOT NULL,
  `signing_key` varchar(256) NOT NULL,
  `document` varchar(256) NOT NULL,
  `company` int(11) NOT NULL,
  `sender` int(11) NOT NULL,
  `receiver` int(11) NOT NULL,
  `email` varchar(128) NOT NULL,
  `positions` text NOT NULL,
  `chain_emails` text DEFAULT NULL,
  `chain_positions` text DEFAULT NULL,
  `sender_note` text DEFAULT NULL,
  `send_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `update_time` datetime DEFAULT NULL,
  `status` enum('Pending','Signed','Declined','Cancelled') NOT NULL DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `permissions` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `settings`
--

CREATE TABLE `settings` (
  `setting_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `setting_value` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `type` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'app',
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `social_links`
--

CREATE TABLE `social_links` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `facebook` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `twitter` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `linkedin` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `googleplus` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `digg` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `youtube` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `pinterest` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `instagram` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `github` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `tumblr` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `vine` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `subdivision_types`
--

CREATE TABLE `subdivision_types` (
  `id` int(11) NOT NULL,
  `title` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `company_name` varchar(50) NOT NULL,
  `address` varchar(150) NOT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'active',
  `color` varchar(7) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `project_id` int(11) NOT NULL,
  `milestone_id` int(11) NOT NULL DEFAULT 0,
  `assigned_to` int(11) NOT NULL,
  `deadline` date DEFAULT NULL,
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `points` tinyint(4) NOT NULL DEFAULT 1,
  `status` enum('to_do','in_progress','done') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'to_do',
  `status_id` int(11) NOT NULL,
  `start_date` date DEFAULT NULL,
  `collaborators` text COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL DEFAULT 0,
  `recurring` tinyint(1) NOT NULL DEFAULT 0,
  `repeat_every` int(11) NOT NULL DEFAULT 0,
  `repeat_type` enum('days','weeks','months','years') COLLATE utf8_unicode_ci DEFAULT NULL,
  `no_of_cycles` int(11) NOT NULL DEFAULT 0,
  `recurring_task_id` int(11) NOT NULL DEFAULT 0,
  `no_of_cycles_completed` int(11) NOT NULL DEFAULT 0,
  `created_date` date NOT NULL,
  `blocking` text COLLATE utf8_unicode_ci NOT NULL,
  `parent_task_id` int(11) NOT NULL,
  `blocked_by` text COLLATE utf8_unicode_ci NOT NULL,
  `next_recurring_date` date DEFAULT NULL,
  `reminder_date` date NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `deleted` tinyint(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `task_status`
--

CREATE TABLE `task_status` (
  `id` int(11) NOT NULL,
  `title` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `key_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `color` varchar(7) COLLATE utf8_unicode_ci NOT NULL,
  `sort` int(11) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `taxes`
--

CREATE TABLE `taxes` (
  `id` int(11) NOT NULL,
  `title` tinytext CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `percentage` double NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `team`
--

CREATE TABLE `team` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `members` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `team_member_job_info`
--

CREATE TABLE `team_member_job_info` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date_of_hire` date DEFAULT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0,
  `salary` double NOT NULL DEFAULT 0,
  `salary_term` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `tickets`
--

CREATE TABLE `tickets` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL DEFAULT 0,
  `ticket_type_id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `status` enum('new','client_replied','open','closed') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'new',
  `last_activity_at` datetime DEFAULT NULL,
  `assigned_to` int(11) NOT NULL DEFAULT 0,
  `creator_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `creator_email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_id` int(11) NOT NULL,
  `closed_at` datetime NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `ticket_comments`
--

CREATE TABLE `ticket_comments` (
  `id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `files` longtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `ticket_types`
--

CREATE TABLE `ticket_types` (
  `id` int(11) NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `timezones`
--

CREATE TABLE `timezones` (
  `id` int(11) NOT NULL,
  `name` varchar(31) NOT NULL,
  `zone` varchar(272) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `to_do`
--

CREATE TABLE `to_do` (
  `id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `title` text COLLATE utf8_unicode_ci NOT NULL,
  `description` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` enum('to_do','done') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'to_do',
  `start_date` date DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `uk_contracts`
--

CREATE TABLE `uk_contracts` (
  `id` int(11) NOT NULL,
  `starred_by` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT 0,
  `created_date` date DEFAULT NULL,
  `internal_ref_num` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `original_con_num` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `signing_date` date DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `period` int(3) DEFAULT NULL,
  `business_class` int(11) DEFAULT NULL,
  `primary_excess` enum('Primary','Excess') COLLATE utf8_unicode_ci DEFAULT NULL,
  `type_of_institution` int(11) DEFAULT NULL,
  `ccy` int(11) DEFAULT NULL,
  `insured_id` int(11) DEFAULT NULL,
  `cedant_id` int(11) DEFAULT NULL,
  `broker_id` int(11) DEFAULT NULL,
  `kyc_check` enum('Yes','No') COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `region` text CHARACTER SET utf8 DEFAULT NULL,
  `gross_limit_ccy_100` double DEFAULT 0,
  `loss_limit_ccy_100` double DEFAULT 0,
  `excess_ccy_100` double DEFAULT 0,
  `gross_premium_ccy_100` double DEFAULT 0,
  `net_premium_ccy_100` double DEFAULT 0,
  `fx_rate` double DEFAULT NULL,
  `gross_limit_usd_100` double DEFAULT 0,
  `loss_limit_usd_100` double DEFAULT 0,
  `excess_usd_100` double DEFAULT 0,
  `gross_premiumt_usd_100` double DEFAULT 0,
  `net_premiumt_usd_100` double DEFAULT 0,
  `order_size` double DEFAULT 0,
  `written_line` double DEFAULT 0,
  `signed_line` double DEFAULT 0,
  `gross_limit_sun_ccy` double DEFAULT 0,
  `loss_limit_ccy_sun` double DEFAULT 0,
  `gross_premium_ccy_sun` double DEFAULT 0,
  `net_premium_ccy_sun` double DEFAULT 0,
  `gross_limit_usd_sun` double DEFAULT 0,
  `loss_limit_usd_sun` double DEFAULT 0,
  `gross_premium_usd_sun` double DEFAULT 0,
  `net_premiumt_usd_sun` double DEFAULT 0,
  `brokerage_per` double DEFAULT 0,
  `ncb_per` double DEFAULT 0,
  `lta_per` double DEFAULT 0,
  `total_deductions_per` double DEFAULT 0,
  `withholding_tax` double DEFAULT 0,
  `deductions_100_usd` double DEFAULT 0,
  `ppw` double DEFAULT 0,
  `premium_schedule` double DEFAULT 0,
  `fx_rate_payment` double DEFAULT 0,
  `paid_prem_net_bank_comission_ccy` double DEFAULT 0,
  `paid_prem_net_bank_comission_usd` double DEFAULT 0,
  `bank_comission_usd` double DEFAULT 0,
  `notes` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `invoice` text CHARACTER SET utf8 DEFAULT NULL,
  `status` enum('open','completed','hold','canceled','changes, closed') COLLATE utf8_unicode_ci DEFAULT 'open',
  `labels` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `last_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `user_type` enum('staff','client','lead') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'client',
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `role_id` int(11) NOT NULL DEFAULT 0,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'active',
  `message_checked_at` datetime DEFAULT NULL,
  `client_id` int(11) NOT NULL DEFAULT 0,
  `notification_checked_at` datetime DEFAULT NULL,
  `is_primary_contact` tinyint(1) NOT NULL DEFAULT 0,
  `job_title` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Untitled',
  `disable_login` tinyint(1) NOT NULL DEFAULT 0,
  `note` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `alternative_address` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `alternative_phone` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `ssn` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `gender` enum('male','female') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'male',
  `sticky_note` mediumtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `skype` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `enable_web_notification` tinyint(1) NOT NULL DEFAULT 1,
  `enable_email_notification` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT NULL,
  `last_online` datetime DEFAULT NULL,
  `requested_account_removal` tinyint(1) NOT NULL DEFAULT 0,
  `signature` varchar(500) COLLATE utf8_unicode_ci DEFAULT NULL,
  `viza` varchar(500) COLLATE utf8_unicode_ci NOT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `verification`
--

CREATE TABLE `verification` (
  `id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `type` enum('invoice_payment','reset_password') COLLATE utf8_unicode_ci NOT NULL,
  `code` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `params` text COLLATE utf8_unicode_ci NOT NULL,
  `deleted` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`);

--
-- Индексы таблицы `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `checked_by` (`checked_by`);

--
-- Индексы таблицы `brokering_projects`
--
ALTER TABLE `brokering_projects`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sender` (`sender`),
  ADD KEY `sender_2` (`sender`),
  ADD KEY `file` (`file`);

--
-- Индексы таблицы `checklist_items`
--
ALTER TABLE `checklist_items`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `ci_sessions`
--
ALTER TABLE `ci_sessions`
  ADD KEY `ci_sessions_timestamp` (`timestamp`);

--
-- Индексы таблицы `class_of_business`
--
ALTER TABLE `class_of_business`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `client_comments`
--
ALTER TABLE `client_comments`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `client_groups`
--
ALTER TABLE `client_groups`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `client_sellers`
--
ALTER TABLE `client_sellers`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `client_status`
--
ALTER TABLE `client_status`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `compliance_list_test`
--
ALTER TABLE `compliance_list_test`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tin` (`tin`);

--
-- Индексы таблицы `countries_list`
--
ALTER TABLE `countries_list`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `currency_list`
--
ALTER TABLE `currency_list`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `custom_fields`
--
ALTER TABLE `custom_fields`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `custom_field_values`
--
ALTER TABLE `custom_field_values`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `custom_widgets`
--
ALTER TABLE `custom_widgets`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `dashboards`
--
ALTER TABLE `dashboards`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `departmentmembers`
--
ALTER TABLE `departmentmembers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `department` (`department`),
  ADD KEY `member` (`member`);

--
-- Индексы таблицы `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company` (`company`);

--
-- Индексы таблицы `email_templates`
--
ALTER TABLE `email_templates`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `estimates`
--
ALTER TABLE `estimates`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `estimate_forms`
--
ALTER TABLE `estimate_forms`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `estimate_items`
--
ALTER TABLE `estimate_items`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `estimate_requests`
--
ALTER TABLE `estimate_requests`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`);

--
-- Индексы таблицы `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `fields`
--
ALTER TABLE `fields`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company` (`company`),
  ADD KEY `user` (`user`);

--
-- Индексы таблицы `files`
--
ALTER TABLE `files`
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `sharing_key` (`document_key`),
  ADD KEY `company` (`company`),
  ADD KEY `uploaded_by` (`uploaded_by`),
  ADD KEY `folder` (`folder`);

--
-- Индексы таблицы `folders`
--
ALTER TABLE `folders`
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `company` (`company`),
  ADD KEY `folder` (`folder`);

--
-- Индексы таблицы `general_files`
--
ALTER TABLE `general_files`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `help_articles`
--
ALTER TABLE `help_articles`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `help_categories`
--
ALTER TABLE `help_categories`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `historical_rate`
--
ALTER TABLE `historical_rate`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `history`
--
ALTER TABLE `history`
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `company` (`company`),
  ADD KEY `file` (`file`),
  ADD KEY `file_2` (`file`);

--
-- Индексы таблицы `insured_list`
--
ALTER TABLE `insured_list`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `invoice_credit_notes`
--
ALTER TABLE `invoice_credit_notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`),
  ADD KEY `id_2` (`id`);

--
-- Индексы таблицы `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `invoice_payments`
--
ALTER TABLE `invoice_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`),
  ADD KEY `id_2` (`id`);

--
-- Индексы таблицы `invoice_scheduled_payments`
--
ALTER TABLE `invoice_scheduled_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`),
  ADD KEY `id_2` (`id`);

--
-- Индексы таблицы `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `leads`
--
ALTER TABLE `leads`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `lead_source`
--
ALTER TABLE `lead_source`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `lead_status`
--
ALTER TABLE `lead_status`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `leave_applications`
--
ALTER TABLE `leave_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `leave_type_id` (`leave_type_id`),
  ADD KEY `user_id` (`applicant_id`),
  ADD KEY `checked_by` (`checked_by`);

--
-- Индексы таблицы `leave_types`
--
ALTER TABLE `leave_types`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `line_of_business`
--
ALTER TABLE `line_of_business`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `message_from` (`from_user_id`),
  ADD KEY `message_to` (`to_user_id`);

--
-- Индексы таблицы `milestones`
--
ALTER TABLE `milestones`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `notification_settings`
--
ALTER TABLE `notification_settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event` (`event`);

--
-- Индексы таблицы `pages`
--
ALTER TABLE `pages`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `paypal_ipn`
--
ALTER TABLE `paypal_ipn`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `project_comments`
--
ALTER TABLE `project_comments`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `project_files`
--
ALTER TABLE `project_files`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `project_members`
--
ALTER TABLE `project_members`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `project_settings`
--
ALTER TABLE `project_settings`
  ADD UNIQUE KEY `unique_index` (`project_id`,`setting_name`);

--
-- Индексы таблицы `project_time`
--
ALTER TABLE `project_time`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `region_list`
--
ALTER TABLE `region_list`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `reinsurer_info`
--
ALTER TABLE `reinsurer_info`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `reminders`
--
ALTER TABLE `reminders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company` (`company`);

--
-- Индексы таблицы `requests`
--
ALTER TABLE `requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `file` (`document`),
  ADD KEY `company` (`company`),
  ADD KEY `user` (`sender`);

--
-- Индексы таблицы `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `settings`
--
ALTER TABLE `settings`
  ADD UNIQUE KEY `setting_name` (`setting_name`);

--
-- Индексы таблицы `social_links`
--
ALTER TABLE `social_links`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `subdivision_types`
--
ALTER TABLE `subdivision_types`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `task_status`
--
ALTER TABLE `task_status`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `taxes`
--
ALTER TABLE `taxes`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `team`
--
ALTER TABLE `team`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `team_member_job_info`
--
ALTER TABLE `team_member_job_info`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `ticket_comments`
--
ALTER TABLE `ticket_comments`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `ticket_types`
--
ALTER TABLE `ticket_types`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `timezones`
--
ALTER TABLE `timezones`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `to_do`
--
ALTER TABLE `to_do`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `uk_contracts`
--
ALTER TABLE `uk_contracts`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_type` (`user_type`),
  ADD KEY `email` (`email`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `deleted` (`deleted`);

--
-- Индексы таблицы `verification`
--
ALTER TABLE `verification`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `brokering_projects`
--
ALTER TABLE `brokering_projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `chat`
--
ALTER TABLE `chat`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `checklist_items`
--
ALTER TABLE `checklist_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `class_of_business`
--
ALTER TABLE `class_of_business`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `client_comments`
--
ALTER TABLE `client_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `client_groups`
--
ALTER TABLE `client_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `client_sellers`
--
ALTER TABLE `client_sellers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `client_status`
--
ALTER TABLE `client_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `compliance_list_test`
--
ALTER TABLE `compliance_list_test`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'skip';

--
-- AUTO_INCREMENT для таблицы `countries_list`
--
ALTER TABLE `countries_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `currency_list`
--
ALTER TABLE `currency_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `custom_fields`
--
ALTER TABLE `custom_fields`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `custom_field_values`
--
ALTER TABLE `custom_field_values`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `custom_widgets`
--
ALTER TABLE `custom_widgets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `dashboards`
--
ALTER TABLE `dashboards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `departmentmembers`
--
ALTER TABLE `departmentmembers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `email_templates`
--
ALTER TABLE `email_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `estimates`
--
ALTER TABLE `estimates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `estimate_forms`
--
ALTER TABLE `estimate_forms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `estimate_items`
--
ALTER TABLE `estimate_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `estimate_requests`
--
ALTER TABLE `estimate_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `fields`
--
ALTER TABLE `fields`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `files`
--
ALTER TABLE `files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `folders`
--
ALTER TABLE `folders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `general_files`
--
ALTER TABLE `general_files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `help_articles`
--
ALTER TABLE `help_articles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `help_categories`
--
ALTER TABLE `help_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `historical_rate`
--
ALTER TABLE `historical_rate`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `history`
--
ALTER TABLE `history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `insured_list`
--
ALTER TABLE `insured_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `invoice_credit_notes`
--
ALTER TABLE `invoice_credit_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `invoice_items`
--
ALTER TABLE `invoice_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `invoice_payments`
--
ALTER TABLE `invoice_payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `invoice_scheduled_payments`
--
ALTER TABLE `invoice_scheduled_payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `leads`
--
ALTER TABLE `leads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `lead_source`
--
ALTER TABLE `lead_source`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `lead_status`
--
ALTER TABLE `lead_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `leave_applications`
--
ALTER TABLE `leave_applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `leave_types`
--
ALTER TABLE `leave_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `line_of_business`
--
ALTER TABLE `line_of_business`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `milestones`
--
ALTER TABLE `milestones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `notes`
--
ALTER TABLE `notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `notification_settings`
--
ALTER TABLE `notification_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `pages`
--
ALTER TABLE `pages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `paypal_ipn`
--
ALTER TABLE `paypal_ipn`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `posts`
--
ALTER TABLE `posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `project_comments`
--
ALTER TABLE `project_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `project_files`
--
ALTER TABLE `project_files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `project_members`
--
ALTER TABLE `project_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `project_time`
--
ALTER TABLE `project_time`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `region_list`
--
ALTER TABLE `region_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `reinsurer_info`
--
ALTER TABLE `reinsurer_info`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `reminders`
--
ALTER TABLE `reminders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `requests`
--
ALTER TABLE `requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `subdivision_types`
--
ALTER TABLE `subdivision_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `task_status`
--
ALTER TABLE `task_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `taxes`
--
ALTER TABLE `taxes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `team`
--
ALTER TABLE `team`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `team_member_job_info`
--
ALTER TABLE `team_member_job_info`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `ticket_comments`
--
ALTER TABLE `ticket_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `ticket_types`
--
ALTER TABLE `ticket_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `timezones`
--
ALTER TABLE `timezones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `to_do`
--
ALTER TABLE `to_do`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `uk_contracts`
--
ALTER TABLE `uk_contracts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `verification`
--
ALTER TABLE `verification`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `files`
--
ALTER TABLE `files`
  ADD CONSTRAINT `files_ibfk_1` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `files_ibfk_2` FOREIGN KEY (`company`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `files_ibfk_3` FOREIGN KEY (`folder`) REFERENCES `folders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
