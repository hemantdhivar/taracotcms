-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1
-- Время создания: Сен 02 2013 г., 01:20
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
-- Структура таблицы `taracot_blog_comments`
--

CREATE TABLE IF NOT EXISTS `taracot_blog_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `deleted` tinyint(1) DEFAULT '0',
  `cusername` varchar(255) NOT NULL,
  `ctext` text,
  `cdate` int(11) DEFAULT NULL,
  `chash` varchar(32) DEFAULT NULL,
  `left_key` int(10) NOT NULL,
  `right_key` int(10) NOT NULL,
  `level` int(10) NOT NULL,
  `ipaddr` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `left_key` (`left_key`,`right_key`,`level`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- Дамп данных таблицы `taracot_blog_comments`
--

INSERT INTO `taracot_blog_comments` (`id`, `post_id`, `deleted`, `cusername`, `ctext`, `cdate`, `chash`, `left_key`, `right_key`, `level`, `ipaddr`) VALUES
(1, 1, 0, 'xtreme', 'Test message', 1375872177, '82dfa5549ebc9afc168eb7931ebece5f', 1, 8, 1, '127.0.0.1'),
(2, 1, 1, 'xtreme', 'It works!', 1375872215, '661d154abfc42a49970f3d53b758fd50', 4, 7, 2, '127.0.0.1'),
(3, 1, 1, 'medved', 'OK OK', 1375962249, 'd19a30d9ba083203e9514f06dbbe9667', 9, 12, 1, '127.0.0.1'),
(4, 1, 0, 'medved', 'OK Computer', 1375974315, 'cc33c5eaa06aeaf631e4c7dcf08eb533', 13, 16, 1, '127.0.0.1'),
(5, 1, 0, 'medved', 'ghfgfg', 1375974390, '6978faa8bdf211745b946971787576c1', 17, 20, 1, '127.0.0.1'),
(6, 1, 0, 'medved', 'Hellow', 1375974428, '0547bca99c4c06f4f614514e3bd2b4e7', 21, 24, 1, '127.0.0.1'),
(7, 1, 1, 'medved', 'WTF?', 1375974461, 'ca948fac1b625e2883a4659bc14e98d2', 25, 28, 1, '127.0.0.1'),
(8, 1, 0, 'medved', 'HEY!', 1375974594, '201bf4a704762707feaec1df2baf205a', 29, 32, 1, '127.0.0.1');

-- --------------------------------------------------------

--
-- Структура таблицы `taracot_blog_posts`
--

CREATE TABLE IF NOT EXISTS `taracot_blog_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plang` varchar(2) DEFAULT NULL,
  `pusername` varchar(255) NOT NULL,
  `phub` varchar(20) DEFAULT NULL,
  `pstate` tinyint(3) DEFAULT '1',
  `ptitle` varchar(255) NOT NULL,
  `ptags` varchar(255) DEFAULT NULL,
  `pdate` int(11) DEFAULT NULL,
  `ptext` text,
  `ptext_html_cut` text,
  `pcut` tinyint(1) DEFAULT '0',
  `ptext_html` text,
  `pviews` int(11) DEFAULT '0',
  `pcomments` int(11) DEFAULT '0',
  `ipaddr` varchar(45) DEFAULT NULL,
  `mod_require` tinyint(1) DEFAULT '0',
  `deleted` tinyint(1) DEFAULT '0',
  `comments_allowed` tinyint(1) DEFAULT '1',
  `lastchanged` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ptags` (`ptags`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Дамп данных таблицы `taracot_blog_posts`
--

INSERT INTO `taracot_blog_posts` (`id`, `plang`, `pusername`, `phub`, `pstate`, `ptitle`, `ptags`, `pdate`, `ptext`, `ptext_html_cut`, `pcut`, `ptext_html`, `pviews`, `pcomments`, `ipaddr`, `mod_require`, `deleted`, `comments_allowed`, `lastchanged`) VALUES
(1, 'en', 'xtreme', 'test1', 1, 'Test post', 'medved, rules', 1375872159, 'Hello world', 'Hello world', 0, 'Hello world', 184, 8, '127.0.0.1', 0, 0, 0, 1376035481),
(2, 'en', 'xtreme', 'test1', 1, 'Ours test', 'OK', 1376037168, 'OK Computer. This post will require the moderation', 'OK Computer. This post will require the moderation', 0, 'OK Computer. This post will require the moderation', 7, 0, '127.0.0.1', 1, 0, 1, 1376037438),
(3, 'en', 'xtreme', 'test1', 1, 'Another post that will require moderation', 'fuck', 1376038355, 'Another post that will require moderation!', 'Another post that will require moderation!', 0, 'Another post that will require moderation!', 5, 0, '127.0.0.1', 1, 0, 1, 1376038355);

-- --------------------------------------------------------

--
-- Структура таблицы `taracot_firewall`
--

CREATE TABLE IF NOT EXISTS `taracot_firewall` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ipaddr` varchar(45) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `lastchanged` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`ipaddr`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `taracot_pages`
--

CREATE TABLE IF NOT EXISTS `taracot_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pagetitle` varchar(255) NOT NULL,
  `keywords` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `content` text,
  `status` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `lang` varchar(5) DEFAULT 'en',
  `layout` varchar(40) NOT NULL DEFAULT 'taracot',
  `lastchanged` int(11) DEFAULT '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `filter` (`pagetitle`,`filename`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Дамп данных таблицы `taracot_pages`
--

INSERT INTO `taracot_pages` (`id`, `pagetitle`, `keywords`, `description`, `content`, `status`, `filename`, `lang`, `layout`, `lastchanged`) VALUES
(1, 'Home', 'Page keywordz', 'Page description', '<p>\n	Hello!</p>\n', 1, '/', 'en', 'taracot', 1358176801);

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
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

--
-- Дамп данных таблицы `taracot_settings`
--

INSERT INTO `taracot_settings` (`id`, `s_name`, `s_value`, `s_value_html`, `lang`, `lastchanged`) VALUES
(1, 'site_title', 'Taracot CMS', '', 'en', 1358181002),
(2, 'site_description', 'This is the global site description', '', 'en', 1350564084),
(3, 'site_keywords', 'these, are, global, site, keywords', '', 'en', 1350564057),
(4, 'blog_hubs', 'test1,Test hub 1;test2,Test hub 2', '', 'en', 1375872043),
(5, 'blog_mode', 'moderate', '<p>Blog mode can be set as:</p>\n\n<ul style="list-style-type:square">\n	<li>public (everyone can create new posts, no moderation)</li>\n	<li>moderate (new posts are created with &quot;mod_require&quot; flag)</li>\n	<li>private (only the users with special permissions are allowed to make new posts)</li>\n</ul>\n', '', 1376033601),
(6, 'support_topics', 'hosting,Hosting problem;design,Web design question', '', 'en', 1378066780);

-- --------------------------------------------------------

--
-- Структура таблицы `taracot_support`
--

CREATE TABLE IF NOT EXISTS `taracot_support` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `susername` varchar(255) NOT NULL,
  `sdate` int(11) NOT NULL,
  `stopic_id` varchar(255) DEFAULT NULL,
  `stopic` varchar(255) DEFAULT NULL,
  `smsg` text,
  `unread` tinyint(4) DEFAULT '0',
  `sstatus` tinyint(2) NOT NULL DEFAULT '0',
  `susername_last` varchar(255) DEFAULT NULL,
  `lastmodified` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Дамп данных таблицы `taracot_support`
--

INSERT INTO `taracot_support` (`id`, `susername`, `sdate`, `stopic_id`, `stopic`, `smsg`, `unread`, `sstatus`, `susername_last`, `lastmodified`) VALUES
(1, 'xtreme', 2147483647, 'hosting', 'Проблемы с сайтом', 'Такие дела, ребятки', 0, 0, 'xtreme', NULL),
(2, 'xtreme', 2147483247, 'billing', 'Платеж не прошел', 'Такие дела, ребятки', 0, 2, 'xtreme', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `taracot_support_ans`
--

CREATE TABLE IF NOT EXISTS `taracot_support_ans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tid` int(11) NOT NULL,
  `susername` varchar(255) DEFAULT NULL,
  `sdate` int(11) DEFAULT NULL,
  `smsg` text,
  `smsg_hash` varchar(32) DEFAULT '',
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=12 ;

--
-- Дамп данных таблицы `taracot_support_ans`
--

INSERT INTO `taracot_support_ans` (`id`, `tid`, `susername`, `sdate`, `smsg`, `smsg_hash`) VALUES
(11, 1, 'xtreme', 1378065826, 'Hello my friends', 'b8432d01870d9b62f299cd4335a0aed7');

-- --------------------------------------------------------

--
-- Структура таблицы `taracot_users`
--

CREATE TABLE IF NOT EXISTS `taracot_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `password` varchar(32) DEFAULT NULL,
  `password_unset` tinyint(1) NOT NULL DEFAULT '0',
  `realname` varchar(100) NOT NULL,
  `email` varchar(80) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `groups` varchar(255) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `verification` varchar(36) DEFAULT NULL,
  `regdate` int(11) DEFAULT NULL,
  `last_lang` varchar(2) DEFAULT NULL,
  `banned` int(11) DEFAULT '0',
  `captcha` tinyint(1) DEFAULT '0',
  `lastchanged` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`username`,`realname`,`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

--
-- Дамп данных таблицы `taracot_users`
--

INSERT INTO `taracot_users` (`id`, `username`, `password`, `password_unset`, `realname`, `email`, `phone`, `groups`, `status`, `verification`, `regdate`, `last_lang`, `banned`, `captcha`, `lastchanged`) VALUES
(1, 'xtreme', '0f5559ee359fba749e7e6638fcfdbbfb', 0, 'Michael Matveev', '', '79217998111', 'blog_post, blog_moderator, blog_moderator_test1', 2, NULL, 1376300791, 'en', 0, 0, 1377974618);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
