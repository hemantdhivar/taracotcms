-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1
-- Время создания: Янв 09 2013 г., 02:10
-- Версия сервера: 5.5.25
-- Версия PHP: 5.3.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `taracot`
--

-- --------------------------------------------------------

--
-- Структура таблицы `taracot_settings`
--

CREATE TABLE IF NOT EXISTS `taracot_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `s_name` varchar(255) NOT NULL,
  `s_value` mediumtext,
  `s_value_html` text,
  `lang` varchar(5) NOT NULL DEFAULT 'en',
  `lastchanged` int(11) DEFAULT '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `s_name` (`s_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=80 AUTO_INCREMENT=28 ;

--
-- Дамп данных таблицы `taracot_settings`
--

INSERT INTO `taracot_settings` (`id`, `s_name`, `s_value`, `s_value_html`, `lang`, `lastchanged`) VALUES
(1, 'site_title', 'Taracot CMS', '', 'en', 1341314543),
(7, 'site_description', 'This is the global site description', '', 'en', 1350564084),
(8, 'catalog_title_cat2', 'Ну вот и что за нафиг?', '<p>\n	РћС‚Р°РєРµ С…СѓР№РЅСЏ, РјР°Р»СЏС‚Р°. РўР°РєРёРµ РґРµР»Р°, СЂРµР±СЏС‚РєРё.<br></p>\n', 'en', 1352462803),
(6, 'site_keywords', 'these, are, global, site, keywords', '', 'en', 1350564057),
(9, 'billing_plan_name_profi', 'Professional', '', 'en', 1353505539),
(10, 'billing_plan_cost_profi', '550', '', '', 1355838493),
(11, 'billing_plan_name_econom', 'Econom', '', 'en', 1353589907),
(12, 'billing_history_domainupdate', 'Domain update', '', 'en', 1353870098),
(13, 'billing_history_domainregister', 'Domain registration', '', 'en', 1353870392),
(14, 'billing_service_name_vps', 'VPS management', '', 'en', 1354698743),
(15, 'billing_service_cost_vps', '123', '', '', 1354698726),
(16, 'billing_service_name_backup', 'Managed backup', '', 'en', 1354701386),
(17, 'billing_service_cost_backup', '666', '', '', 1354701407),
(18, 'billing_currency', 'RUR', '', 'en', 1355609052),
(19, 'billing_payment_webmoney', 'Webmoney', '<p>\n	A multifunctional payment tool that provides secure and immediate transactions online</p>\n', 'en', 1355232452),
(20, 'billing_payment_robokassa', 'Robokassa', '<p>\n	Payments in every e-currency, using mobile commerce services (MTS, Megafon, Beeline), e-invoicing via leading banks in Russia, through ATMs, through instant payment terminals, through Contact remittances, and with the iPhone application</p>\n', 'en', 1355232538),
(21, 'billing_history_addfunds', 'Funds deposit', '', 'en', 1355393623),
(22, 'billing_plan_cost_econom', '199', '', '', 1355593214),
(23, 'billing_history_hostingupdate', 'Hosting account update', '', 'en', 1355656040),
(24, 'billing_domain_zone_ru', '500,400', '', '', 1355837400),
(25, 'billing_domain_zone_com', '500', '', '', 1355837411),
(26, 'billing_nss_ns1', 'ns1.re-hash.org', '', '', 1357642095),
(27, 'billing_nss_ns2', 'ns2.re-hash.org', '', '', 1357642114);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
