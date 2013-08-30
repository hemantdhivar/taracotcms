-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Aug 30, 2013 at 06:16 PM
-- Server version: 5.0.45
-- PHP Version: 5.2.4
-- 
-- Database: `taracot`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_bills`
-- 

CREATE TABLE `taracot_billing_bills` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `amount` float NOT NULL,
  `created` int(11) NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 AUTO_INCREMENT=18 ;

-- 
-- Dumping data for table `taracot_billing_bills`
-- 

INSERT INTO `taracot_billing_bills` VALUES (1, 1, 14, 1377513180);
INSERT INTO `taracot_billing_bills` VALUES (2, 1, 14, 1377516960);
INSERT INTO `taracot_billing_bills` VALUES (3, 1, 14, 1377519963);
INSERT INTO `taracot_billing_bills` VALUES (4, 1, 14, 1377522088);
INSERT INTO `taracot_billing_bills` VALUES (5, 1, 14, 1377522176);
INSERT INTO `taracot_billing_bills` VALUES (6, 1, 14, 1377522181);
INSERT INTO `taracot_billing_bills` VALUES (7, 1, 14, 1377522204);
INSERT INTO `taracot_billing_bills` VALUES (8, 1, 14, 1377522208);
INSERT INTO `taracot_billing_bills` VALUES (9, 1, 14, 1377522217);
INSERT INTO `taracot_billing_bills` VALUES (10, 1, 14, 1377522287);
INSERT INTO `taracot_billing_bills` VALUES (11, 1, 14, 1377522343);
INSERT INTO `taracot_billing_bills` VALUES (12, 1, 14, 1377522347);
INSERT INTO `taracot_billing_bills` VALUES (13, 1, 14, 1377522348);
INSERT INTO `taracot_billing_bills` VALUES (14, 1, 14, 1377522351);
INSERT INTO `taracot_billing_bills` VALUES (15, 1, 14, 1377522355);
INSERT INTO `taracot_billing_bills` VALUES (16, 1, 14, 1377522358);
INSERT INTO `taracot_billing_bills` VALUES (17, 1, 14, 1377523108);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_domains`
-- 

CREATE TABLE `taracot_billing_domains` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `domain_name` varchar(255) NOT NULL,
  `exp_date` int(11) default NULL,
  `error_msg` varchar(255) NOT NULL,
  `ns1` varchar(80) default NULL,
  `ns2` varchar(80) default NULL,
  `ns3` varchar(80) default NULL,
  `ns4` varchar(80) default NULL,
  `ns1_ip` varchar(42) default NULL,
  `ns2_ip` varchar(42) default NULL,
  `ns3_ip` varchar(42) default NULL,
  `ns4_ip` varchar(42) default NULL,
  `remote_ip` varchar(42) default NULL,
  `in_queue` tinyint(1) NOT NULL default '0',
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `domain_name` (`domain_name`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=43 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_billing_domains`
-- 

INSERT INTO `taracot_billing_domains` VALUES (2, 1, 'test.com', 2147483647, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_funds`
-- 

CREATE TABLE `taracot_billing_funds` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL default '0',
  `amount` float NOT NULL default '0',
  `lastchanged` int(11) default NULL,
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=17 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `taracot_billing_funds`
-- 

INSERT INTO `taracot_billing_funds` VALUES (1, 1, 13100, 1377518901);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_funds_history`
-- 

CREATE TABLE `taracot_billing_funds_history` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `trans_id` varchar(255) default NULL,
  `trans_objects` varchar(255) default NULL,
  `trans_amount` float NOT NULL default '0',
  `trans_date` int(11) NOT NULL,
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `trans_amount` (`trans_objects`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=60 AUTO_INCREMENT=4 ;

-- 
-- Dumping data for table `taracot_billing_funds_history`
-- 

INSERT INTO `taracot_billing_funds_history` VALUES (1, 1, 'domainupdate', 'test.com', -500, 1377516728, 1377516728);
INSERT INTO `taracot_billing_funds_history` VALUES (2, 1, 'serviceupdate', 'srv1', -200, 1377517050, 1377517050);
INSERT INTO `taracot_billing_funds_history` VALUES (3, 1, 'serviceupdate', 'srv1', -200, 1377518901, 1377518901);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_hosting`
-- 

CREATE TABLE `taracot_billing_hosting` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `host_acc` varchar(255) default NULL,
  `host_plan_id` varchar(255) default NULL,
  `host_days_remain` int(11) default '0',
  `host_days_last` int(11) default NULL,
  `pwd` varchar(80) default NULL,
  `error_msg` varchar(255) default NULL,
  `in_queue` tinyint(1) NOT NULL default '0',
  `lastchanged` int(11) default '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `host_acc` (`host_acc`)
) ENGINE=MyISAM AUTO_INCREMENT=116 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=40 AUTO_INCREMENT=116 ;

-- 
-- Dumping data for table `taracot_billing_hosting`
-- 

INSERT INTO `taracot_billing_hosting` VALUES (115, 1, 'test', 'sample', 30, NULL, NULL, NULL, 0, 0);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_profiles`
-- 

CREATE TABLE `taracot_billing_profiles` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `n1r` varchar(30) default NULL,
  `n1e` varchar(30) default NULL,
  `n2r` varchar(30) default NULL,
  `n2e` varchar(30) default NULL,
  `n3r` varchar(30) default NULL,
  `n3e` varchar(30) default NULL,
  `email` varchar(90) default NULL,
  `phone` varchar(20) default NULL,
  `fax` varchar(20) default NULL,
  `country` varchar(2) default NULL,
  `city` varchar(80) default NULL,
  `state` varchar(40) default NULL,
  `addr` varchar(80) default NULL,
  `postcode` varchar(10) default NULL,
  `passport` varchar(255) default NULL,
  `birth_date` varchar(10) default NULL,
  `addr_ru` varchar(255) default NULL,
  `org` varchar(80) default NULL,
  `org_r` varchar(80) default NULL,
  `code` varchar(12) default NULL,
  `kpp` varchar(9) default NULL,
  `private` tinyint(4) default NULL,
  `lastchanged` int(11) default NULL,
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 
-- Dumping data for table `taracot_billing_profiles`
-- 


-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_queue`
-- 

CREATE TABLE `taracot_billing_queue` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `action` varchar(80) NOT NULL,
  `object` varchar(80) NOT NULL,
  `lang` varchar(2) default NULL,
  `tstamp` int(11) NOT NULL,
  `amount` float NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `taracot_billing_queue`
-- 

INSERT INTO `taracot_billing_queue` VALUES (1, 1, 'domainupdate', 'test.com', 'en', 1377516728, 500);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_billing_services`
-- 

CREATE TABLE `taracot_billing_services` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `service_id` varchar(255) default NULL,
  `service_days_remaining` int(11) NOT NULL,
  `error_msg` varchar(255) default NULL,
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `service_name` (`service_id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 AUTO_INCREMENT=11 ;

-- 
-- Dumping data for table `taracot_billing_services`
-- 

INSERT INTO `taracot_billing_services` VALUES (10, 1, 'srv1', 71, NULL, 1377518901);

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

INSERT INTO `taracot_pages` VALUES (1, 'Home', 'taracot, sample, homepage', 'Taracot sample homepage', '<p>If you can read this, everything seems to work fine.</p>\n\n<p>Please log in to <a href="/admin">administration panel</a> to perform website configuration and administration.</p>\n', 1, '/', 'en', 'taracot', 1376571456);

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
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=17 ;

-- 
-- Dumping data for table `taracot_settings`
-- 

INSERT INTO `taracot_settings` VALUES (1, 'site_title', 'Taracot CMS', '', 'en', 1358181002);
INSERT INTO `taracot_settings` VALUES (2, 'site_description', 'Taracot CMS installation is running', '', 'en', 1376571472);
INSERT INTO `taracot_settings` VALUES (3, 'site_keywords', 'taracot cms, perl, dancer', '', 'en', 1376571477);
INSERT INTO `taracot_settings` VALUES (4, 'blog_hubs', 'test1,Test hub one;test2,Test hub two', '', 'en', 1376571488);
INSERT INTO `taracot_settings` VALUES (5, 'blog_mode', 'moderate', '<p>Blog mode can be set as:</p>\n\n<ul style="list-style-type:square">\n	<li>public (everyone can create new posts, no moderation)</li>\n	<li>moderate (new posts are created with &quot;mod_require&quot; flag)</li>\n	<li>private (only the users with special permissions are allowed to make new posts)</li>\n</ul>\n', '', 1376033601);
INSERT INTO `taracot_settings` VALUES (6, 'blog_items_per_page', '10', '', '', 1376571169);
INSERT INTO `taracot_settings` VALUES (7, 'billing_nss_1', 'ns1.re-hash.org', '', '', 1377511711);
INSERT INTO `taracot_settings` VALUES (8, 'billing_nss_2', 'ns2.re-hash.org', '', '', 1377511727);
INSERT INTO `taracot_settings` VALUES (9, 'billing_domain_zone_com', '500', '', '', 1377511780);
INSERT INTO `taracot_settings` VALUES (10, 'billing_plan_name_sample', 'Sample plan', '', 'en', 1377513246);
INSERT INTO `taracot_settings` VALUES (11, 'billing_plan_cost_sample', '100', '', '', 1377511826);
INSERT INTO `taracot_settings` VALUES (12, 'billing_service_name_srv1', 'Sample Service', '', 'en', 1377512113);
INSERT INTO `taracot_settings` VALUES (13, 'billing_service_cost_srv1', '200', '', '', 1377512896);
INSERT INTO `taracot_settings` VALUES (14, 'billing_payment_webmoney', 'Webmoney', '<p>Help text for webmoney</p>\n', 'en', 1377512939);
INSERT INTO `taracot_settings` VALUES (15, 'billing_payment_robokassa', 'Robokassa', '<p>Help text for Robokassa</p>\n', 'en', 1377513065);
INSERT INTO `taracot_settings` VALUES (16, 'billing_currency', 'RUR', '', 'en', 1377513285);

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
  `lastmodified` int(11) default NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_support`
-- 

INSERT INTO `taracot_support` VALUES (1, 'xtreme', 2147483647, 'hosting', 'Проблемы с сайтом', 'Такие дела, ребятки', 0, 0, 'xtreme', NULL);
INSERT INTO `taracot_support` VALUES (2, 'xtreme', 2147483247, 'billing', 'Платеж не прошел', 'Такие дела, ребятки', 0, 2, 'xtreme', NULL);

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
  `lastmodified` int(11) NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_support_ans`
-- 

INSERT INTO `taracot_support_ans` VALUES (1, 1, 'xtreme', 2147483647, 'Hello world! Seems that it works ;)', 0);
INSERT INTO `taracot_support_ans` VALUES (2, 1, 'zhoposhnique', 2147444647, 'Another one!', 0);

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
  `banned` int(11) default '0',
  `captcha` tinyint(1) default '0',
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ftdata` (`username`,`realname`,`email`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_users`
-- 

INSERT INTO `taracot_users` VALUES (1, 'xtreme', '0f5559ee359fba749e7e6638fcfdbbfb', 0, 'Michael Matveev', '', '79217998111', 'blog_post, blog_moderator, blog_moderator_test1', 2, NULL, 1376300791, 'en', 0, 0, 1377856253);
INSERT INTO `taracot_users` VALUES (2, 'user', '702dc357740e3b83a19940d5ceba6bc7', 0, '', 'xtreme@rh1.ru', '1234567', '', 1, NULL, NULL, 'en', 1376731887, 0, 1376558949);
