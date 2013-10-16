-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Oct 16, 2013 at 05:18 PM
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
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `taracot_blog_comments`
-- 


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
  `phash` varchar(255) default NULL,
  `ptext` text,
  `ptext_html_cut` text,
  `pcut` tinyint(1) default '0',
  `ptext_html` text,
  `pviews` int(11) default '0',
  `pcomments` int(11) default '0',
  `ipaddr` varchar(45) default NULL,
  `mod_require` tinyint(1) default '0',
  `deleted` tinyint(1) default '0',
  `comments_allowed` tinyint(1) default '1',
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ptags` (`ptags`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `taracot_blog_posts`
-- 


-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_catalog`
-- 

CREATE TABLE `taracot_catalog` (
  `id` int(11) NOT NULL auto_increment,
  `pagetitle` varchar(255) NOT NULL,
  `keywords` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `cat_text` text,
  `content` text,
  `status` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `category` bigint(12) default '0',
  `lang` varchar(5) default 'en',
  `layout` varchar(40) NOT NULL default 'taracot',
  `lastchanged` int(11) default '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `filter` (`pagetitle`,`filename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `taracot_catalog`
-- 


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
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 AUTO_INCREMENT=1 ;

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
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `taracot_pages`
-- 

INSERT INTO `taracot_pages` VALUES (1, '/', 'home', 'Home page', '<h1>Installation successful</h1>\n\n<p>As you can read this text, the installation seems to be sucessful.</p>\n', 1, '/', 'en', 'taracot', 1381929026);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_search_db`
-- 

CREATE TABLE `taracot_search_db` (
  `module_id` varchar(20) NOT NULL default '',
  `ref_id` int(11) NOT NULL default '0',
  `slang` varchar(2) default 'en',
  `stitle` varchar(255) default NULL,
  `stext` text,
  `swords` text,
  `surl` varchar(255) default NULL,
  `lastchanged` int(11) default NULL,
  PRIMARY KEY  (`ref_id`,`module_id`),
  FULLTEXT KEY `swords` (`swords`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 
-- Dumping data for table `taracot_search_db`
-- 

INSERT INTO `taracot_search_db` VALUES ('pages', 1, 'en', '/', 'As you can read this text, the installation seems to be sucessful.', 'sucessful the  you seems installation can to as be text read this', '/', 1381929026);

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
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=5 ;

-- 
-- Dumping data for table `taracot_settings`
-- 

INSERT INTO `taracot_settings` VALUES (1, 'site_title', 'Taracot CMS', '', 'en', 1358181002);
INSERT INTO `taracot_settings` VALUES (2, 'site_description', 'Taracot CMS installation is running', '', 'en', 1376571472);
INSERT INTO `taracot_settings` VALUES (3, 'site_keywords', 'taracot cms, perl, dancer', '', 'en', 1376571477);
INSERT INTO `taracot_settings` VALUES (4, 'support_topics', 'sample,Sample topic;misc,Misc topic', '', 'en', 1381928970);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_support`
-- 

CREATE TABLE `taracot_support` (
  `id` int(11) NOT NULL auto_increment,
  `susername` varchar(255) NOT NULL,
  `sdate` int(11) NOT NULL,
  `stopic_id` varchar(255) default NULL,
  `stopic` varchar(255) default NULL,
  `smsg` text,
  `unread` tinyint(4) default '0',
  `sstatus` tinyint(2) NOT NULL default '0',
  `susername_last` varchar(255) default NULL,
  `smsg_hash` varchar(32) default NULL,
  `lastmodified` int(11) default NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `taracot_support`
-- 


-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_support_ans`
-- 

CREATE TABLE `taracot_support_ans` (
  `id` int(11) NOT NULL auto_increment,
  `tid` int(11) NOT NULL,
  `susername` varchar(255) default NULL,
  `sdate` int(11) default NULL,
  `smsg` text,
  `smsg_hash` varchar(32) default '',
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `taracot_support_ans`
-- 


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
  `email_save` varchar(80) default NULL,
  `email_save_verification` varchar(32) default NULL,
  `phone` varchar(40) default NULL,
  `groups` varchar(255) default NULL,
  `status` tinyint(4) NOT NULL default '0',
  `verification` varchar(36) default NULL,
  `regdate` int(11) default NULL,
  `last_lang` varchar(2) default NULL,
  `banned` int(11) default '0',
  `captcha` tinyint(1) default '0',
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`username`,`realname`,`email`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_users`
-- 

INSERT INTO `taracot_users` VALUES (1, 'xtreme', '0f5559ee359fba749e7e6638fcfdbbfb', 0, 'Michael Matveev', '', NULL, NULL, '79217998111', 'blog_post, blog_moderator, blog_moderator_test1', 2, NULL, 1376300791, 'en', 0, 0, 1381922651);
INSERT INTO `taracot_users` VALUES (2, 'user', '1d88c84caa93404ecf250399bc1be5a0', 1, 'John Doe', '', NULL, NULL, '79217998111', '', 1, NULL, NULL, 'en', 1376731887, 0, 1379770337);
