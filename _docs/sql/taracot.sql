-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Aug 07, 2013 at 06:50 PM
-- Server version: 5.0.45
-- PHP Version: 5.2.4
-- 
-- Database: `taracot`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_blog_comments`
-- 

CREATE TABLE `taracot_blog_comments` (
  `id` int(11) NOT NULL auto_increment,
  `post_id` int(11) NOT NULL,
  `deleted` tinyint(1) default '0',
  `cusername` varchar(255) NOT NULL,
  `ctext` text,
  `cdate` int(11) default NULL,
  `chash` varchar(32) default NULL,
  `left_key` int(10) NOT NULL,
  `right_key` int(10) NOT NULL,
  `level` int(10) NOT NULL,
  `ipaddr` varchar(45) default NULL,
  PRIMARY KEY  (`id`),
  KEY `left_key` (`left_key`,`right_key`,`level`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_blog_comments`
-- 

INSERT INTO `taracot_blog_comments` VALUES (1, 1, 0, 'xtreme', 'Test message', 1375872177, '82dfa5549ebc9afc168eb7931ebece5f', 1, 8, 1, '127.0.0.1');
INSERT INTO `taracot_blog_comments` VALUES (2, 1, 0, 'xtreme', 'It works!', 1375872215, '661d154abfc42a49970f3d53b758fd50', 4, 7, 2, '127.0.0.1');

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_blog_posts`
-- 

CREATE TABLE `taracot_blog_posts` (
  `id` int(11) NOT NULL auto_increment,
  `plang` varchar(2) default NULL,
  `pusername` varchar(255) NOT NULL,
  `phub` varchar(20) default NULL,
  `pstate` tinyint(3) default '1',
  `ptitle` varchar(255) NOT NULL,
  `ptags` varchar(255) default NULL,
  `pdate` int(11) default NULL,
  `ptext` text,
  `ptext_html_cut` text,
  `pcut` tinyint(1) default '0',
  `ptext_html` text,
  `pviews` int(11) default '0',
  `pcomments` int(11) default '0',
  `ipaddr` varchar(45) default NULL,
  `mod_require` tinyint(1) default '0',
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ptags` (`ptags`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `taracot_blog_posts`
-- 

INSERT INTO `taracot_blog_posts` VALUES (1, 'en', 'xtreme', 'test1', 1, 'Test post', 'medved, rules', 1375872159, 'Hello world', 'Hello world', 0, 'Hello world', 5, 2, '127.0.0.1', 0, 1375872159);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_firewall`
-- 

CREATE TABLE `taracot_firewall` (
  `id` int(11) NOT NULL auto_increment,
  `ipaddr` varchar(45) default NULL,
  `status` tinyint(4) NOT NULL default '0',
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`ipaddr`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `taracot_firewall`
-- 


-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_pages`
-- 

CREATE TABLE `taracot_pages` (
  `id` int(11) NOT NULL auto_increment,
  `pagetitle` varchar(255) NOT NULL,
  `keywords` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `content` text,
  `status` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `lang` varchar(5) default 'en',
  `layout` varchar(40) NOT NULL default 'taracot',
  `lastchanged` int(11) default '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `filter` (`pagetitle`,`filename`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `taracot_pages`
-- 

INSERT INTO `taracot_pages` VALUES (1, 'Home', 'Page keywordz', 'Page description', '<p>\n	Hello!</p>\n', 1, '/', 'en', 'taracot', 1358176801);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_settings`
-- 

CREATE TABLE `taracot_settings` (
  `id` int(11) NOT NULL auto_increment,
  `s_name` varchar(255) NOT NULL,
  `s_value` mediumtext,
  `s_value_html` text,
  `lang` varchar(5) NOT NULL default 'en',
  `lastchanged` int(11) default '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `s_name` (`s_name`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

-- 
-- Dumping data for table `taracot_settings`
-- 

INSERT INTO `taracot_settings` VALUES (1, 'site_title', 'Taracot CMS', '', 'en', 1358181002);
INSERT INTO `taracot_settings` VALUES (2, 'site_description', 'This is the global site description', '', 'en', 1350564084);
INSERT INTO `taracot_settings` VALUES (3, 'site_keywords', 'these, are, global, site, keywords', '', 'en', 1350564057);
INSERT INTO `taracot_settings` VALUES (4, 'blog_hubs', 'test1,Test hub 1;test2,Test hub 2', '', 'en', 1375872043);
INSERT INTO `taracot_settings` VALUES (5, 'blog_mode', 'private', '<p>Blog mode can be set as:</p>\r\n\r\n<ul style="list-style-type: square;">\r\n	<li>public (everyone can create new posts, no moderation)</li>\r\n	<li>moderate (new posts are created with &quot;mod_require&quot; flag)</li>\r\n	<li>private (only the users with special permissions are allowed to make new posts)</li>\r\n</ul>\r\n', '', 1375881134);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_users`
-- 

CREATE TABLE `taracot_users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(100) NOT NULL,
  `password` varchar(32) default NULL,
  `password_unset` tinyint(1) NOT NULL default '0',
  `realname` varchar(100) NOT NULL,
  `email` varchar(80) NOT NULL,
  `phone` varchar(40) default NULL,
  `groups` varchar(255) default NULL,
  `status` tinyint(4) NOT NULL default '0',
  `verification` varchar(36) default NULL,
  `regdate` int(11) default NULL,
  `last_lang` varchar(2) default NULL,
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`username`,`realname`,`email`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_users`
-- 

INSERT INTO `taracot_users` VALUES (1, 'xtreme', 'f4932e9f0bd95a312bb5e0409ca3c804', 0, '', '', '', 'blog_post', 1, NULL, 1375879219, 'en', 1375885118);
INSERT INTO `taracot_users` VALUES (2, 'medved', 'bce6f24a213ca19ec34dab4c3f2a37ab', 0, '', '', '', '', 2, NULL, NULL, 'en', 1375880553);
