-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Sep 13, 2013 at 05:41 PM
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
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_pages`
-- 

INSERT INTO `taracot_pages` VALUES (1, 'Home', 'taracot, sample, homepage', 'Taracot sample homepage', '<p>If you can read this, everything seems to work fine.</p>\n\n<p>Please log in to <a href="/admin">administration panel</a> to perform website configuration and administration.</p>\n', 1, '/', 'en', 'taracot', 1379063010);
INSERT INTO `taracot_pages` VALUES (2, 'Такие дела', 'taracot, sample, homepage', 'Taracot sample homepage', '<p>Слухи об&nbsp;обновлённой линейке планшетов Kindle Fire от&nbsp;Amazon ходят ещё с&nbsp;середины лета, но&nbsp;компания, почему-то, пока не&nbsp;торопится проводить презентацию, ограничившись тихим анонсом нового ридера Kindle Paperwhite. Несмотря на&nbsp;это, об&nbsp;этих устройствах продолжают появляться новые сообщения из&nbsp;неофициальных источников, а, значит, они действительно могут быть в&nbsp;скором времени представлены. Сейчас же речь пойдёт о&nbsp;7-дюймовой &laquo;таблетке&raquo; Amazon Kindle Fire HD, фотографии которой были опубликованы в&nbsp;сети. And it&#39;s fine! Вот так вот, да.</p>', 1, '/tiestovaia_stranitsa', 'ru', 'taracot', 1379063065);

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

INSERT INTO `taracot_search_db` VALUES ('pages', 2, 'ru', 'Такие дела', 'Слухи об обновлённой линейке планшетов Kindle Fire от Amazon ходят ещё с середины лета, но компания, почему-то, пока не торопится проводить презентацию, ограничившись тихим анонсом нового ридера Ki...', 'сейчас да устройствах вот из пока fine от таблетке its об amazon ещё планшетов были hd kindle нового быть неофициальных же сети опубликованы and проводить о источников так но paperwhite на сообщения анонсом фотографии дела лета ходят слухи тихим почему-то скором 7-дюймовой презентацию речь обновлённой ридера действительно представлены пойдёт они продолжают в новые а торопится которой это несмотря ограничившись не с fire появляться этих значит компания линейке такие могут середины времени', '/tiestovaia_stranitsa', 1379063065);
INSERT INTO `taracot_search_db` VALUES ('pages', 1, 'en', 'Home', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 3, 'en', 'Home3', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 5, 'en', 'Home5', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 4, 'en', 'Home4', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 6, 'en', 'Home6', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 7, 'en', 'Home7', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 8, 'en', 'Home8', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 9, 'en', 'Home9', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 31, 'en', 'Home31', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 32, 'en', 'Home32', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 33, 'en', 'Home33', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 34, 'en', 'Home34', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 41, 'en', 'Home41', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 42, 'en', 'Home42', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 43, 'en', 'Home43', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 44, 'en', 'Home44', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 443, 'en', 'Home443', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 3333, 'en', 'Home3333', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 312, 'en', 'Home123', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);
INSERT INTO `taracot_search_db` VALUES ('pages', 322, 'en', 'Home322', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration. ...', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/', 1379063010);

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
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=19 ;

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
INSERT INTO `taracot_settings` VALUES (17, 'support_topics', 'hosting,Hosting problem;design,Web design question;billing,Billing questions', '', 'en', 1378066780);
INSERT INTO `taracot_settings` VALUES (18, 'support_mail', 'billing=xtreme@re-hash.ru, billing@re-hash.ru;hosting=hosting@rh1.ru;all=all@rh1.ru', '', '', 1378123809);

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
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 AUTO_INCREMENT=19 ;

-- 
-- Dumping data for table `taracot_support`
-- 

INSERT INTO `taracot_support` VALUES (1, 'xtreme', 1378120863, 'hosting', 'Проблемы с сайтом', 'Такие дела, ребятки', 0, 2, 'xtreme', NULL, 1378120863);
INSERT INTO `taracot_support` VALUES (2, 'xtreme', 1378115335, 'billing', 'Платеж не прошел', 'Такие дела, ребятки', 0, 1, 'xtreme', NULL, 1378119342);
INSERT INTO `taracot_support` VALUES (3, 'xtreme', 1378111611, 'hosting', 'OK', 'Seems that it <span style="color:#ff0000;"><b>WORKS</b></span>!', 0, 0, 'xtreme', 'ad452c565318eba7340a6fce960975e3', 1378119074);
INSERT INTO `taracot_support` VALUES (4, 'xtreme', 1378111689, 'design', 'What a phuck!', 'I think everything works', 0, 0, 'xtreme', '0afbe40e4e3a9e6708a5a06977078e85', 1378118856);
INSERT INTO `taracot_support` VALUES (5, 'xtreme', 1378120824, 'hosting', 'Another one &amp;lt;b&amp;gt;', 'I hope this works', 0, 2, 'xtreme', 'ee7675194bb6ade48928af36f1ef594d', 1378120824);
INSERT INTO `taracot_support` VALUES (6, 'xtreme', 1378120855, 'hosting', 'Let''s give it another try &amp;', 'OK computer', 0, 2, 'xtreme', '7dac61b6f631968b53580e99ac67a00c', 1378120855);
INSERT INTO `taracot_support` VALUES (7, 'xtreme', 1378111832, 'hosting', 'hey hey', 'hey hey', 0, 0, 'xtreme', '04f9c51a0070f3456eb7682d11449c3e', NULL);
INSERT INTO `taracot_support` VALUES (8, 'xtreme', 1378120751, 'hosting', 'The last one', 'OK Computer', 0, 2, 'xtreme', 'cc33c5eaa06aeaf631e4c7dcf08eb533', 1378120751);
INSERT INTO `taracot_support` VALUES (9, 'xtreme', 1378112590, 'hosting', 'Презентация Samsung и Sony', 'И Samsung, и&nbsp;Sony уже давно объявили о&nbsp;том, что намереваются провести презентации своих новинок в&nbsp;один день&nbsp;&mdash; 4 сентября в&nbsp;Берлине, но&nbsp;до сегодняшнего дня мы не&nbsp;могли и&nbsp;предположить, когда именно Galaxy Note III и&nbsp;Xperia Z1 (это название получило дополнительное подтверждение) можно будет купить в&nbsp;ритейле. Даты выхода в&nbsp;продажу смартпэда Samsung и&nbsp;коммуникатора Sony, к&nbsp;счастью, оказались разными. Первым жители Великобритании увидят Samsung Galaxy Note III, а&nbsp;за ним, через&nbsp;10 дней, последует и&nbsp;Sony Xperia Z1, релиз которого намечен на&nbsp;24 сентября. Зарубежный ресурс Engadget, который и&nbsp;получил фотографию, размещённую выше, отмечает, что нет никакой точно информации, что Three UK получит устройства первым, а, значит, каждый из&nbsp;аппаратов может выйти в&nbsp;продажу и&nbsp;раньше. Но если в&nbsp;случае с&nbsp;устройством японской компании это предположение не&nbsp;лишено смысла, то южнокорейский производитель, как&nbsp;и в&nbsp;случае с&nbsp;Galaxy S IV, скорее всего, начнёт продажи смартпэда одновременно во&nbsp;многих странах&hellip; Что ж, было бы интересно увидеть Galaxy Note III в&nbsp;нашей стране уже меньше, чем через&nbsp;месяц, но, всё же, &laquo;дождёмся для&nbsp;начала его анонса&raquo;.', 0, 0, 'xtreme', 'dfad0bcb6020236675fe957512c87bf7', 1378119271);
INSERT INTO `taracot_support` VALUES (10, 'user', 1378122896, 'design', 'Ни хрена не работает', 'И какого, спрашивается, чорта?<br />\n<br />\n<img src="http://i.blog.fontanka.ru/photos/2013/09/220x220_dLR16SGX1B1HXZ7i9TV9.jpg" width="90" height="60" alt="" border="0" /> ', 1, 1, 'xtreme', '4d3dfa98e0243018e85ef48dc93ddeab', 1378122896);
INSERT INTO `taracot_support` VALUES (11, 'xtreme', 1378123597, 'hosting', 'OK', 'Hellow', 0, 0, 'xtreme', '0547bca99c4c06f4f614514e3bd2b4e7', NULL);
INSERT INTO `taracot_support` VALUES (12, 'xtreme', 1378123699, 'hosting', 'OK Computer', 'Helloooow', 0, 0, 'xtreme', '8ddbecace17618bc4942cb3a54c34e3e', NULL);
INSERT INTO `taracot_support` VALUES (13, 'xtreme', 1378123720, 'billing', 'Yep', 'yep', 0, 0, 'xtreme', '9348ae7851cf3ba798d9564ef308ec25', NULL);
INSERT INTO `taracot_support` VALUES (14, 'xtreme', 1378123877, 'hosting', 'OK All', 'yeeeep', 0, 0, 'xtreme', 'e7fbd5c08a4fbec53bff0ff5ba49fc07', NULL);
INSERT INTO `taracot_support` VALUES (15, 'xtreme', 1378123908, 'hosting', 'Another one', 'Hey hey hey', 0, 0, 'xtreme', '7fc8d5ba5078256a5280aba339cbb0b0', NULL);
INSERT INTO `taracot_support` VALUES (16, 'xtreme', 1378123936, 'hosting', 'd2', 'd2', 0, 0, 'xtreme', 'b25b0651e4b6e887e5194135d3692631', NULL);
INSERT INTO `taracot_support` VALUES (17, 'xtreme', 1378123951, 'billing', 'BQ', 'BBQ', 0, 0, 'xtreme', '709cf76964bf6b2149e7a8040fa24cf5', NULL);
INSERT INTO `taracot_support` VALUES (18, 'xtreme', 1378125358, 'design', 'WDQ', 'WDQ', 0, 0, 'xtreme', '58afb946581d678ab24c42be9a309cda', 1378125358);

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
) ENGINE=MyISAM AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 AUTO_INCREMENT=34 ;

-- 
-- Dumping data for table `taracot_support_ans`
-- 

INSERT INTO `taracot_support_ans` VALUES (11, 1, 'xtreme', 1378065826, 'Hello my friends', 'b8432d01870d9b62f299cd4335a0aed7');
INSERT INTO `taracot_support_ans` VALUES (12, 1, 'xtreme', 1378112197, 'Let me give it a reply', '40dc9e058aee95150d36396828ead8c1');
INSERT INTO `taracot_support_ans` VALUES (13, 2, 'xtreme', 1378112211, 'This too :&#41;', '59b00d94941a057b87607397ed06f0aa');
INSERT INTO `taracot_support_ans` VALUES (14, 1, 'xtreme', 1378112219, 'Another one', '15b9246f433cd82a982f12092075a1fe');
INSERT INTO `taracot_support_ans` VALUES (15, 9, 'xtreme', 1378112567, '&amp;lt&#59;script language=&#34;javascript&#34;&amp;gt&#59;alert&#40;&#39;fail fail fail&#39;&#41;&#59;&amp;lt&#59;/script&amp;gt&#59;', '8412ed9f6eed9d4b4187d98ebb4fd8d1');
INSERT INTO `taracot_support_ans` VALUES (16, 9, 'xtreme', 1378112590, '&amp;lt&#59;/panel&amp;gt&#59;&amp;lt&#59;script language=&#34;javascript&#34;&amp;gt&#59;alert&#40;&#39;fail fail fail&#39;&#41;&#59;&amp;lt&#59;/script&amp;gt&#59;<br />\n&#34;&amp;gt&#59;&amp;lt&#59;script language=&#34;javascript&#34;&amp;gt&#59;alert&#40;&#39;fail fail fail&#39;&#41;&#59;&amp;lt&#59;/script&amp;gt&#59;<br />\n&#39;&amp;gt&#59;&amp;lt&#59;script language=&#34;javascript&#34;&amp;gt&#59;alert&#40;&#39;fail fail fail&#39;&#41;&#59;&amp;lt&#59;/script&amp;gt&#59;', '7b34c36a5745db310a183e3cfa082ef6');
INSERT INTO `taracot_support_ans` VALUES (17, 2, 'xtreme', 1378115335, 'И тем не&nbsp;менее:)', 'a876504d90a2d1786bebbc1089ddb9be');
INSERT INTO `taracot_support_ans` VALUES (18, 10, 'user', 1378119965, 'Требую ответа!', 'b71eee9a76946dad8925c2b578aeae68');
INSERT INTO `taracot_support_ans` VALUES (19, 10, 'xtreme', 1378120011, 'Не волнуся, чуваке, всё путем.', '9f5090c85302e818c59970ed002c3c72');
INSERT INTO `taracot_support_ans` VALUES (20, 10, 'xtreme', 1378120065, 'Щас всё починим.', 'a02b5a574b0dac2c9866d5ac8d02baa2');
INSERT INTO `taracot_support_ans` VALUES (21, 8, 'xtreme', 1378120751, 'All necessary actions on a problem were accepted. The ticked is closed.', '');
INSERT INTO `taracot_support_ans` VALUES (22, 5, 'xtreme', 1378120824, 'All necessary actions on a problem were accepted. The ticked is closed.', '');
INSERT INTO `taracot_support_ans` VALUES (23, 6, 'xtreme', 1378120855, 'All necessary actions on a problem were accepted. The ticked is closed.', '');
INSERT INTO `taracot_support_ans` VALUES (24, 1, 'xtreme', 1378120862, 'Рун', 'daf603576bf0b73342a9fb33d18239fc');
INSERT INTO `taracot_support_ans` VALUES (25, 1, 'xtreme', 1378120863, 'All necessary actions on a problem were accepted. The ticked is closed.', '');
INSERT INTO `taracot_support_ans` VALUES (26, 10, 'xtreme', 1378120895, 'All necessary actions on a problem were accepted. The ticked is closed.', '');
INSERT INTO `taracot_support_ans` VALUES (27, 10, 'user', 1378120922, 'Ни хренашечки подобного.', '2465d02ceaca7b495b51596f37bb8650');
INSERT INTO `taracot_support_ans` VALUES (28, 10, 'xtreme', 1378121112, 'All necessary actions on a problem were accepted. The ticked is closed.', '');
INSERT INTO `taracot_support_ans` VALUES (29, 10, 'user', 1378122795, 'Нет.', '873ee3393e1a8e2ac4f3f120a199bc1b');
INSERT INTO `taracot_support_ans` VALUES (30, 10, 'xtreme', 1378122834, 'Ну чуваааааааак, как это - не работает?', '387dd1dbd27b1f26f02757e93dd69814');
INSERT INTO `taracot_support_ans` VALUES (31, 10, 'xtreme', 1378122865, 'Ну чуваааааааак, как это - не работает?!', '79ef0944c5ed8a824c45d333ab45ff86');
INSERT INTO `taracot_support_ans` VALUES (32, 10, 'xtreme', 1378122896, 'Ну чуваааааааак, как это - не работает?!!', 'ec1b77d231a0824b064fc5e6ff602c3f');
INSERT INTO `taracot_support_ans` VALUES (33, 18, 'xtreme', 1378125358, 'Пейшу ответ.', 'a2a97c35be4b3d5608170882b5cd53a9');

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

INSERT INTO `taracot_users` VALUES (1, 'xtreme', '0f5559ee359fba749e7e6638fcfdbbfb', 0, 'Michael Matveev', '', '79217998111', 'blog_post, blog_moderator, blog_moderator_test1', 2, NULL, 1376300791, 'en', 0, 0, 1378999113);
INSERT INTO `taracot_users` VALUES (2, 'user', '0f5559ee359fba749e7e6638fcfdbbfb', 0, '', 'xtreme@rh1.ru', '1234567', '', 1, NULL, NULL, 'en', 1376731887, 0, 1378119910);
