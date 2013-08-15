-- phpMyAdmin SQL Dump
-- version 3.2.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 15, 2013 at 12:52 PM
-- Server version: 5.1.40
-- PHP Version: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `taracot`
--

-- --------------------------------------------------------

--
-- Table structure for table `taracot_blog_comments`
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
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `taracot_blog_comments`
--

INSERT INTO `taracot_blog_comments` (`id`, `post_id`, `deleted`, `cusername`, `ctext`, `cdate`, `chash`, `left_key`, `right_key`, `level`, `ipaddr`) VALUES
(1, 3, 1, 'user', 'OK OK', 1376302539, 'd19a30d9ba083203e9514f06dbbe9667', 1, 4, 1, '127.0.0.1'),
(2, 3, 1, 'user', 'Should NOT work', 1376302652, '50855fefc907db1452fd2d43a4f9b1c0', 5, 8, 1, '127.0.0.1'),
(3, 3, 0, 'user', 'Let me comment please', 1376491996, '1ce607f27547d0fbacd854fe5520bc6d', 9, 12, 1, '127.0.0.1'),
(4, 3, 0, 'user', 'This is my comment', 1376492187, '0e886c4da79bb479b61054641ec13950', 13, 16, 1, '127.0.0.1');

-- --------------------------------------------------------

--
-- Table structure for table `taracot_blog_posts`
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
  `phash` varchar(255) DEFAULT NULL,
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
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=11 ;

--
-- Dumping data for table `taracot_blog_posts`
--

INSERT INTO `taracot_blog_posts` (`id`, `plang`, `pusername`, `phub`, `pstate`, `ptitle`, `ptags`, `pdate`, `phash`, `ptext`, `ptext_html_cut`, `pcut`, `ptext_html`, `pviews`, `pcomments`, `ipaddr`, `mod_require`, `deleted`, `comments_allowed`, `lastchanged`) VALUES
(1, 'en', 'xtreme', 'test1', 1, 'Test topic', 'Hello world', 1376300975, NULL, 'OK Computer', 'OK Computer', 0, 'OK Computer', 10, 0, '127.0.0.1', 0, 0, 1, 1376300975),
(2, 'en', 'user', 'test1', 1, 'Test pre-mod', 'hello, world', 1376301244, NULL, 'Yeah.', 'Yeah.', 0, 'Yeah.', 5, 0, '127.0.0.1', 0, 0, 1, 1376301244),
(3, 'en', 'user', 'test1', 1, 'This should be working', 'test, test', 1376301894, NULL, 'Must be pub for everyone', 'Must be pub for everyone', 0, 'Must be pub for everyone', 66, 4, '127.0.0.1', 0, 0, 1, 1376310507),
(4, 'en', 'user', 'test1', 1, 'A', 'A', 1376496572, 'e1faffb3e614e6c2fba74296962386b7', 'AAA', 'AAA', 0, 'AAA', 0, 0, '127.0.0.1', 1, 0, 1, 1376496572),
(5, 'en', 'user', 'test1', 1, 'A', 'A', 1376496590, 'e1faffb3e614e6c2fba74296962386b7', 'AAA', 'AAA', 0, 'AAA', 1, 0, '127.0.0.1', 1, 0, 1, 1376496590),
(6, 'en', 'user', 'test1', 1, 'A', 'A', 1376496615, '7fc56270e7a70fa81a5935b72eacbe29', 'A', 'A', 0, 'A', 0, 0, '127.0.0.1', 1, 0, 1, 1376496615),
(7, 'en', 'user', 'test1', 1, 'A', 'A', 1376496621, '7fc56270e7a70fa81a5935b72eacbe29', 'A', 'A', 0, 'A', 1, 0, '127.0.0.1', 1, 0, 1, 1376496621),
(8, 'en', 'user', 'test1', 1, 'A', 'A', 1376496910, '7fc56270e7a70fa81a5935b72eacbe29', 'A', 'A', 0, 'A', 0, 0, '127.0.0.1', 1, 0, 1, 1376496910),
(9, 'en', 'user', 'test1', 1, 'A', 'A', 1376496932, '7fc56270e7a70fa81a5935b72eacbe29', 'A', 'A', 0, 'A', 0, 0, '127.0.0.1', 1, 0, 1, 1376496932),
(10, 'en', 'xtreme', 'test1', 1, 'A', 'B', 1376558154, '5d28b1ca4ed7ed365431dac89d9b3fea', 'У одного моего знакомого™, помнится, была такая «система для безлимитных звонков». Приходили на телефонную станцию — там стояли междугородние автоматы… то время подавляющее число таксофонов не имело номера телефона (не определялось АОНами) или имело номер телефона с категорией «3» (без права выхода на междугороднюю связь). С таксофона не было возможности позвонить на межгород. Я проверил международные таксофоны в городе, все они были на обычных телефонных номерах с категорией «1». Номер телефона международного таксофона был написан в будке на специальном шильдике. Мой домашний телефон принадлежал самой старой АТС из трех в нашем городе, в отличии от других АТС в городе, он не определялся АОНами, и чтоб позвонить по межгороду мне приходилась набирать 8 номер телефона куда я хочу позвонить, свой номер телефона. АТС меня отсоединяла, и перенабирала заново, потом соединяло с набранным номером.', 'У одного моего знакомого™, помнится, была такая &laquo;система для&nbsp;безлимитных звонков&raquo;. Приходили на&nbsp;телефонную станцию&nbsp;&mdash; там стояли междугородние автоматы&hellip; то время подавляющее число таксофонов не&nbsp;имело номера телефона &#40;не определялось АОНами&#41; или&nbsp;имело номер телефона с&nbsp;категорией &laquo;3&raquo; &#40;без права выхода на&nbsp;междугороднюю связь&#41;. С таксофона не&nbsp;было возможности позвонить на&nbsp;межгород. Я проверил международные таксофоны в&nbsp;городе, все они были на&nbsp;обычных телефонных номерах с&nbsp;категорией &laquo;1&raquo;. Номер телефона международного таксофона был написан в&nbsp;будке на&nbsp;специальном шильдике. Мой домашний телефон принадлежал самой старой АТС из&nbsp;трех в&nbsp;нашем городе, в&nbsp;отличии от&nbsp;других АТС в&nbsp;городе, он не&nbsp;определялся АОНами, и&nbsp;чтоб позвонить по&nbsp;межгороду мне приходилась набирать 8 номер телефона куда я хочу позвонить, свой номер телефона. АТС меня отсоединяла, и&nbsp;перенабирала заново, потом соединяло с&nbsp;набранным номером.', 0, 'У одного моего знакомого™, помнится, была такая &laquo;система для&nbsp;безлимитных звонков&raquo;. Приходили на&nbsp;телефонную станцию&nbsp;&mdash; там стояли междугородние автоматы&hellip; то время подавляющее число таксофонов не&nbsp;имело номера телефона &#40;не определялось АОНами&#41; или&nbsp;имело номер телефона с&nbsp;категорией &laquo;3&raquo; &#40;без права выхода на&nbsp;междугороднюю связь&#41;. С таксофона не&nbsp;было возможности позвонить на&nbsp;межгород. Я проверил международные таксофоны в&nbsp;городе, все они были на&nbsp;обычных телефонных номерах с&nbsp;категорией &laquo;1&raquo;. Номер телефона международного таксофона был написан в&nbsp;будке на&nbsp;специальном шильдике. Мой домашний телефон принадлежал самой старой АТС из&nbsp;трех в&nbsp;нашем городе, в&nbsp;отличии от&nbsp;других АТС в&nbsp;городе, он не&nbsp;определялся АОНами, и&nbsp;чтоб позвонить по&nbsp;межгороду мне приходилась набирать 8 номер телефона куда я хочу позвонить, свой номер телефона. АТС меня отсоединяла, и&nbsp;перенабирала заново, потом соединяло с&nbsp;набранным номером.', 10, 0, '127.0.0.1', 0, 0, 1, 1376563724);

-- --------------------------------------------------------

--
-- Table structure for table `taracot_firewall`
--

CREATE TABLE IF NOT EXISTS `taracot_firewall` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ipaddr` varchar(45) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `lastchanged` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`ipaddr`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `taracot_firewall`
--


-- --------------------------------------------------------

--
-- Table structure for table `taracot_pages`
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
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `taracot_pages`
--

INSERT INTO `taracot_pages` (`id`, `pagetitle`, `keywords`, `description`, `content`, `status`, `filename`, `lang`, `layout`, `lastchanged`) VALUES
(1, 'Home', 'Page keywords', 'Page description', '<p>\nHello! As you can read this, everything seems to be working fine.</p>\n', 1, '/', 'en', 'taracot', 1358176801);

-- --------------------------------------------------------

--
-- Table structure for table `taracot_settings`
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
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `taracot_settings`
--

INSERT INTO `taracot_settings` (`id`, `s_name`, `s_value`, `s_value_html`, `lang`, `lastchanged`) VALUES
(1, 'site_title', 'Taracot CMS', '', 'en', 1358181002),
(2, 'site_description', 'This is the global site description', '', 'en', 1350564084),
(3, 'site_keywords', 'these, are, global, site, keywords', '', 'en', 1350564057),
(4, 'blog_hubs', 'test1,Test hub 1;test2,Test hub 2', '', 'en', 1375872043),
(5, 'blog_mode', 'moderate', '<p>Blog mode can be set as:</p>\n\n<ul style="list-style-type:square">\n	<li>public (everyone can create new posts, no moderation)</li>\n	<li>moderate (new posts are created with &quot;mod_require&quot; flag)</li>\n	<li>private (only the users with special permissions are allowed to make new posts)</li>\n</ul>\n', '', 1376033601);

-- --------------------------------------------------------

--
-- Table structure for table `taracot_users`
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
-- Dumping data for table `taracot_users`
--

INSERT INTO `taracot_users` (`id`, `username`, `password`, `password_unset`, `realname`, `email`, `phone`, `groups`, `status`, `verification`, `regdate`, `last_lang`, `banned`, `captcha`, `lastchanged`) VALUES
(1, 'xtreme', '0f5559ee359fba749e7e6638fcfdbbfb', 0, 'Michael Matveev', '', '79217998111', 'blog_post, blog_moderator, blog_moderator_test1', 2, NULL, 1376300791, 'en', 0, 0, 1376560952),
(2, 'user', '702dc357740e3b83a19940d5ceba6bc7', 0, '', 'xtreme@rh1.ru', '1234567', '', 1, NULL, NULL, 'en', 1376731887, 0, 1376558949);
