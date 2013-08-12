-- phpMyAdmin SQL Dump
-- version 3.2.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 12, 2013 at 06:27 PM
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
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `taracot_blog_comments`
--

INSERT INTO `taracot_blog_comments` (`id`, `post_id`, `deleted`, `cusername`, `ctext`, `cdate`, `chash`, `left_key`, `right_key`, `level`, `ipaddr`) VALUES
(1, 3, 1, 'user', 'OK OK', 1376302539, 'd19a30d9ba083203e9514f06dbbe9667', 1, 4, 1, '127.0.0.1'),
(2, 3, 1, 'user', 'Should NOT work', 1376302652, '50855fefc907db1452fd2d43a4f9b1c0', 5, 8, 1, '127.0.0.1');

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
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `taracot_blog_posts`
--

INSERT INTO `taracot_blog_posts` (`id`, `plang`, `pusername`, `phub`, `pstate`, `ptitle`, `ptags`, `pdate`, `ptext`, `ptext_html_cut`, `pcut`, `ptext_html`, `pviews`, `pcomments`, `ipaddr`, `mod_require`, `deleted`, `comments_allowed`, `lastchanged`) VALUES
(1, 'en', 'xtreme', 'test1', 1, 'Test topic', 'Hello world', 1376300975, 'OK Computer', 'OK Computer', 0, 'OK Computer', 8, 0, '127.0.0.1', 1, 0, 1, 1376300975),
(2, 'en', 'user', 'test1', 1, 'Test pre-mod', 'hello, world', 1376301244, 'Yeah.', 'Yeah.', 0, 'Yeah.', 2, 0, '127.0.0.1', NULL, 0, 1, 1376301244),
(3, 'en', 'user', 'test1', 1, 'This should be working', 'test, test', 1376301894, 'Must be pub for everyone', 'Must be pub for everyone', 0, 'Must be pub for everyone', 35, 2, '127.0.0.1', 1, 1, 1, 1376310507);

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
  `lastchanged` int(11) DEFAULT NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`username`,`realname`,`email`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `taracot_users`
--

INSERT INTO `taracot_users` (`id`, `username`, `password`, `password_unset`, `realname`, `email`, `phone`, `groups`, `status`, `verification`, `regdate`, `last_lang`, `banned`, `lastchanged`) VALUES
(1, 'xtreme', '0f5559ee359fba749e7e6638fcfdbbfb', 0, '', '', NULL, NULL, 2, NULL, 1376300791, 'en', 0, 1376303028),
(2, 'user', '702dc357740e3b83a19940d5ceba6bc7', 0, '', '', '', '', 1, NULL, NULL, 'en', 0, 1376301596);
