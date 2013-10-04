-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Oct 04, 2013 at 05:14 PM
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
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `taracot_blog_posts`
-- 

INSERT INTO `taracot_blog_posts` VALUES (1, 'en', 'user', 'test1', 1, 'Test', 'Test post', 1379678788, '4f043e973014aa5fbf7af9af50bcdb50', '[img width=484,height=426]http://habr.habrastorage.org/post_images/015/db5/df7/015db5df78926f182640cefa14e5de7a.jpg[/img]', '<img src="http://habr.habrastorage.org/post_images/015/db5/df7/015db5df78926f182640cefa14e5de7a.jpg" width="484" height="426" alt="" border="0" /> ', 0, '<img src="http://habr.habrastorage.org/post_images/015/db5/df7/015db5df78926f182640cefa14e5de7a.jpg" width="484" height="426" alt="" border="0" /> ', 1, 0, '127.0.0.1', 1, 0, 1, 1379678788);

-- --------------------------------------------------------

-- 
-- Table structure for table `taracot_catalog`
-- 

CREATE TABLE `taracot_catalog` (
  `id` int(11) NOT NULL auto_increment,
  `pagetitle` varchar(255) NOT NULL,
  `keywords` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `content` text,
  `status` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `category` bigint(12) default '0',
  `lang` varchar(5) default 'en',
  `layout` varchar(40) NOT NULL default 'taracot',
  `lastchanged` int(11) default '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `filter` (`pagetitle`,`filename`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- 
-- Dumping data for table `taracot_catalog`
-- 

INSERT INTO `taracot_catalog` VALUES (1, 'Test item', '', '', '<p>OK Computer</p>\n', 1, '/', 1380712146944, 'en', 'taracot', 1380886960);

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

INSERT INTO `taracot_search_db` VALUES ('pages', 1, 'en', 'Home', 'If you can read this, everything seems to work fine. Please log in to administration panel to perform website configuration and administration.', 'website you administration panel if to in fine read configuration log home this perform seems work can everything please and', '/pages/', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('pages', 2, 'ru', 'Такие дела', 'Слухи об обновлённой линейке планшетов Kindle Fire от Amazon ходят ещё с середины лета, но компания, почему-то, пока не торопится проводить презентацию, ограничившись тихим...', 'сейчас речь с середины да устройствах вот действительно ридера пока представлены на это пойдёт они fine из неофициальных об этих таблетке its продолжают amazon ещё в сети планшетов были hd а новые об обновлённой kindle нового быть же не торопится которой опубликованы and проводить источников несмотря так в скором paperwhite ограничившись сообщения анонсом fire фотографии о 7-дюймовой дела лета ходят слухи появляться тихим от amazon значит почему-то линейке могут такие времени но компания презентацию', '/pages/tiestovaia_stranitsa', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 1, 'en', 'Publishing house "Lema"', 'OOO "publishing house "Lema"" has been in the printing industry market since 2001. The main products include books, catalogues, magazines, brochures, booklets, leaflets, stickers,...', 'market the customized catalogues since has booklets etc leaflets in business ooo products printing full 2001 main brochures cycle magazines include books advantages deadlines manufacturing controlled been labels house publishing industry accurate stickers lema cards approach', '/portfolio/lemaprint', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 2, 'en', 'International alliance "Labour Migration"', 'The alliance consolidates organizations whose work in the sphere of migration is based on steadfast adherence to the legislation requirements. Their concerted effort resulted in defining the principle...', 'russia establishing the elaborating these standard commonwealth network resulted a documents which concerned projects steadfast regulatory employment on participates in alliance approaches methods contracts legislation also based course out cooperation private principles regions standards their with and labour practical effort sphere worked of states are whose is independent to use agencies adherence migration employers work requirements uniform defining consolidates organizations then concerted utilized international', '/portfolio/ialm', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 3, 'en', 'Company website "Hotel-Express"', 'The company provides services in hotel booking in Moscow, Saint-Petersburg, all over Russia, the Ukraine, the Republic of Belarus, as well as health and spa resorts, holiday hotels in Moscow Region', 'russia the over website of all booking in ukraine company holiday resorts hotels services region hotel-express health spa hotel well provides as belarus moscow saint-petersburg and republic', '/portfolio/hotelex', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 4, 'en', 'Security provider "Tverichanin"', 'Security provider "Tverichanin" was opened at the beginning of 2008. Key services include physical security, security systems installation, consulting in the sphere of safety and security. T...', 'the provider sphere of include tverichanin installation safety key systems in at company physical control consulting beginning access services 2008 specializes opened was security and', '/portfolio/tverichanin', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 5, 'en', 'Company website "Interno"', 'Construction company "Interno" is engaged in interior design', 'website engaged interno is design construction interior in company', '/portfolio/interno', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 6, 'en', 'Ekaterina Lebedeva photographer website', 'For Ekaterina the most exciting in photography – is to catch an unusual shot and make a portrait of any ordinary person lively and remarkable. Each person possesses a unique identity, and the ph...', 'unusual photography the website a remarkable in commitment its shot unique lively show each for possesses uniqueness lebedeva portrait and most of is photographer to person beauty ordinary make ekaterina photographs any identity catch exciting an', '/portfolio/fotikmotik', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 7, 'en', 'Website for trash bar-cafe "Cynic"', 'If you want to soak in the atmosphere of St. Petersburg underground, get a taste of the unique club decor, experience fresh audio-visual curiosities - in the very centre of St. Petersburg you will fin...', 'want you another experience club if cynic informal elementsdj bar nest beat atmosphere communitiesas first-hand break out unique petersburg styles rock-n-roll st casual freedom open people arranged trash uncle dance inclines curiosities hardly vip- djs with cozy and sincerety prices plainness youth of taste find underground - good to soak овцебосх from formal will vova something house variety audio-visual single directions live fascinating feelings the website a posh uncensored cultural xtreme talented in rock needless music bar-cafe centre democratic very for freindly decor hall everything outing such wi-fi ambience concerts especially karaoke retro warm-hearted say get ordinary anyone emotions lounge unconventional jazz fresh mix dj well as', '/portfolio/cynic', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 8, 'en', 'Outsourcing company "Prof-Expert"', 'Outsourcing company "Prof-Expert" – is a solid professional aggressive team. The employees regularly improve their skills, all of them possess certifications of professional accountant...', 'the solid a which skills courses experience allows seminars aggressive on least years keep in participate academy legislation problems each sector them finance updates certifications audit accountants their accounting with and team conferences possess employees of commands prof-expert up are is all regularly advanced training to employee basis at current dedicated professional company attend outsourcing improve yearly work 12 members international', '/portfolio/osprof', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 9, 'en', '"Energoconsultant" Ltd.', '"Energoconsultant" Ltd. carries out technical control, testing and analysis; scientific research and development in the fields of natural and technical sciences; software engineering and con...', 'the testing educational natural technical further in engineering this out institutions for analysis development carries with and scientific sphere ltd of research energoconsultant advanced control consulting trainings education higher specialists sciences software fields vocational', '/portfolio/energocon', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 10, 'en', 'Moscow city booking agency "Hotel Express Company" Ltd.', 'On the website you can inform yourself about hotels, have a look at the photos of the rooms, select a hotel according to your budget, obtain a brief overview of the town, its population, administrativ...', 'population the website a yourself you town booking express on about its code obtain according overview administrative your and tourist photos zone time ltd of budget brief look rooms city to bodies have at agency company select hotels attractions inform can hotel dialing moscow', '/portfolio/exh', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 11, 'en', 'Online publication system for the newspaper "Vacansia"', 'Newspaper "Vacansia от А до Я" comes out in Moscow, Saint-Petersburg and Ekaterinburg', 'the system до newspaper in я от vacansia comes out for а online moscow saint-petersburg publication ekaterinburg and', '/portfolio/vak', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 12, 'en', 'Company website of "AvtoDiK"', 'AvtoDiK is always ready to help you solve problems with your car. Key activities include pruchasing broken automobiles, defective and meant for utilization; dismantling foreign-made and local cars, se...', 'website you key providing cars problems always foreign-made utilization tow for meant selling your ready spare and with dismantling solve automobiles of activities include is broken local to avtodik help trucks company secondhand towing car pruchasing defective parts', '/portfolio/razborka', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 13, 'en', 'Company website "Les Tut"', 'The company has been engaged in wooden house building for 10 years. Specialists from Kirov produce the best timber block homes and cottages from the top quality logs, as well as timber saunas and summ...', 'the les website produce has houses years in carpenters own its also saunas cottages tut for region summer materials top kirov building best 10 areas and constructors of teams cutting engaged homes logs manufacturing been from company quality house it wooden specialists well construction as employs runs block owns timber', '/portfolio/lestut', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 14, 'en', 'Humanities e-library E-Lingvo.net', 'E-Lingvo.net is the largest online library in the Russian Internet dedicated to humanities. Here you will find scientific articles and researches written by famous literary scholars and linguists in E...', 'the you e-lingvonet etc in e-library articles internet russian researches by lectures other literary scholars and here scientific written library is find famous english exam to french sheets will languages dedicated german crib humanities online textbooks linguists largest', '/portfolio/e-lingvo', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 15, 'en', 'Music band website "Markscheider Kunst"', '«Markscheider Kunst» is a music group created in 1992 by geology students in Saint-Petersburg. In the early years the musicians prefered hard rockabilly style which was gradually diluted by blues elem...', 'the website a which latin years in music jamaica themes elements gradually rockabilly by kunst saint-petersburg and hard band markscheider later is group musicians early blues students ethnical prefered style diluted created was geology 1992 enriched', '/portfolio/mkunst', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 16, 'en', 'Company website "Ulov 10 tonn"', 'The company provides services in renting fishing bases on the territory of Russia', 'russia territory bases the website of tonn renting on in company services provides fishing 10 ulov', '/portfolio/ulov100', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 17, 'en', 'Konstantin Shutov photographer website', 'Professional photographer Konstantin Shutov performs a wide variety of assignments including interior, landscape photography, studio shootings, portrait and still-life photography, portfolio, differen...', 'photography website a photo shootings of photographer interior session assignments professional wide photojournalism konstantin including portfolio variety wedding studio work different kinds still-life and portrait landscape performs shutov', '/portfolio/fotokost', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 18, 'en', 'KS Motors company official website', 'KS Motors is one of the major dealers of used cars from the USA, Canada and Germany in Saint-Petersburg market. KS Motors guarantees you a good bargain purchase, as well as safe delivery on time. You...', 'market the ks website a you delivery usa on guarantees dealers cars in extra benefit canada also safe bargain catalogue germany one saint-petersburg used and official major extended several time of is registration good renewd from motors company week services car purchase can well as times', '/portfolio/ksmotors', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 19, 'en', 'Rental office "Arendadel"', 'On the website "Arendadel" you can rent or let out apartments, homes without middlemen, in all Russian towns. Payment service provider is integrated, flexible administrative facilities along...', 'provider the website you along integrated apartments on let or in rental out russian service administrative arendadel with are homes rent all is design laconic middlemen towns flexible payment provided without can office facilities', '/portfolio/arendadel', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 20, 'en', 'Promotional materials and signature style of the cafe "Cynic"', 'Legendary trash bar-cafe "Cynic"', 'the cafe of style cynic trash promotional materials signature bar-cafe and legendary', '/portfolio/cynic_style', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 21, 'en', 'Accounting system for KS Motors company', 'KS Motors is one of the major dealers of used cars from the USA, Canada and Germany in Saint-Petersburg market', 'market the ks system of usa is dealers cars in from motors canada company for germany one saint-petersburg used accounting and major', '/portfolio/ksdb', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 22, 'en', 'Expenditure account system KS Motors', 'KS Motors is one of the major dealers of used cars from the USA, Canada and Germany in Saint-Petersburg market', 'market the ks system of usa is dealers cars in from motors canada expenditure account germany one saint-petersburg used and major', '/portfolio/ksacc', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 23, 'en', 'HTML Generator', 'HTML Generator is a program for easy and handy creation of website pages! The program enables you to select a style of webpages or create your own one, customize any settings, place your webpages on t...', 'the website you a along activex etc program generator on or own internet russian for dynamic assistant one your helpful with and start pages lot interesting of place handy is to html will help get much select create language enables java style getting any supported settings perl textbooks easy started more creation webpages customize an', '/portfolio/hg', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 24, 'en', 'Bubble Breaker', 'Bubble Breaker is an entertaining logical game for your Android device. It is absolutely free of charge and does not contain any ads!This version features:- Full HD graphic support (up to 19...', 'the breaker windows modes not android in sound- does features- for hd playing 1920x1980- graphic full logical contain daynight switching different your entertaining and four support of same up mobile is to free adsthis absolutely it original version version- any comfortable device as charge bubble game an', '/portfolio/bubblebreaker', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 25, 'ru', 'Издательство «Лема»', 'OOO «Издательство "ЛЕМА"» работает на полиграфическом рынке с 2001 года. Основными видами изготовляемой продукции являются: книги, каталоги, журналы, брошюры, буклеты, листовки,...', 'являются работает производства лема контролируемые брошюры ooo рынке издательство визитки основными многое 2001 изготовляемой журналы индивидуальный наклейки полный полиграфическом каталоги листовки на и с цикл преимущества технологический продукции года сроки этикетки подход книги видами буклеты другое четкие', '/portfolio/lemaprint', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 26, 'ru', 'Сайт Международного альянса «Трудовая миграция»', 'Под эгидой МАТМ объединились организации, деятельность которых в сфере миграции осуществляется на основе неукоснительного соблюдения требований законодательства. Объединенными усилиями члены МАТМ смог...', 'россии агентств сотрудничестве занятости проектах стандарты трудовая использовании сформулировать единообразных требований сети смогли о усилиями работодателей матм миграции на применении и основе практического снг сфере организации разрабатываемых регионах эгидой частных договоров объединенными чаз-ов чазов формируемые альянса под типовых правовых соблюдения в неукоснительного международного применение находят нормативных практическое сайт члены принципы участием методов осуществляется объединились базируется с деятельность документов миграция государствах-участниках законодательства которых подходов взаимодействия результате формирования', '/portfolio/ialm', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 27, 'ru', 'Сайт компании «Отель-экспресс»', 'Компания предоставляет услуги по бронированию номеров гостиниц Москвы, Санкт-Петербурга, всей России, Украины и Республики Беларусь, а также домов отдыха, санаториев и пансионатов в Подмосковье.', 'россии услуги по предоставляет и пансионатов также всей в домов гостиниц подмосковье а москвы номеров беларусь компания отдыха бронированию сайт санкт-петербурга украины республики санаториев отель-экспресс компании', '/portfolio/hotelex', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 28, 'ru', 'Охранное предприятие «Тверичанин»', 'Охранная организация «Тверичанин» создана в начале 2008 г. Основная сфера предоставляемых нами охранных услуг - физическая охрана объектов. Также организация оказывает услуги по установке охранных сис...', 'услуги создана охране специализируется по начале безопасности также физическая организация в охранного объектов 2008 предоставляемых нами охраны оборудования оказывает услуг систем охранное охрана тверичанин на установке предоставляет - и с охранная сфера основная вопросам предприятие консультации контрольно-пропускном г режимом охранных', '/portfolio/tverichanin', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 29, 'ru', 'Сайт компании «Интерно»', 'Строительная компания «Интерно» занимается разработкой дизайна и оформлением квартир.', 'квартир дизайна интерно строительная разработкой компания и оформлением сайт занимается компании', '/portfolio/interno', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 30, 'ru', 'Сайт фотографа Екатерины Лебедевой', 'Для Екатерины самое увлекательное в работе фотографа – «поймать» необыкновенный кадр и сделать потрет даже самого обычного человека ярким и интересным. Каждый человек обладает уникальным внутрен...', 'работе потрет самого поймать миром внутренним каждый для в самое лебедевой сделать интересным даже человек сайт показать увлекательное и фотографа обычного кадр уникальность личности екатерины уникальным красоту задача необыкновенный ярким человека обладает', '/portfolio/fotikmotik', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 31, 'ru', 'Сайт треш-бар-кафе «Циник»', 'Хотите погрузиться в атмосферу питерского андеграунда, прикоснуться взглядом к необычному клубному антуражу, завладеть свежими звуко-визуальными впечатлениями? В самом центре Питера для Вас есть нечто...', 'живой молодежи купюр сложно есть погрузиться от только для искренней выбор место rock-n-roll встретить еще к услышать джаз будет демократическое вова нечто за свободы со уютный особенно найдете трэш-пафосное самом культпоход непринужденности антуражу по вас необычному простоте множеством в своему эмоций рок интересное сайт музыкальных обстановка где-нибудь что-нибудь клубов заведение это завладеть особенное уголок впрочем хотите не атмосферу звуко-визуальными питерских разнообразие мере питерского хороших элементами ретро дядя взглядом андеграунда нормальными треш-бар-кафе beat break демократичное сможете неформальные людей среди же впечатлениями себя vip- направлений вы танц-холл располагающая на и овцебосх прикоснуться house свежими питера один душевное нормальное баром клубному до приветливый j xtreme центре зал стилей настенных этакое всё условностей розеток без музыку wi-fi диджейство с ощутите обстановку полной здесь циник вкусу хорошим чувств ценами lounge объединения mix приятый караоке dj концертах конечно', '/portfolio/cynic', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 32, 'ru', 'Аутсорсинговая компания «Проф-Эксперт»', 'Аутсорсинговая компания «Проф-Эксперт» – это сплоченный, профессионально-грамотный, энергичный коллектив. Специалисты компании постоянно совершенствуют свои навыки, все сотрудники Ау...', 'академии законодательстве являются финансовом проблемам коллектив квалификации навыки от совершенствуют аудита актуальным сплоченный профессионально-грамотный лет в свои аутсорсинговая курсе имеют быть постоянно работы посвященных энергичный позволяет компании это аутсорсинговой повышения членами ежегодно сотрудники участвуют учета и что конференциях курсы проф-эксперт профессиональный бухгалтеров стаж все сотрудника семинарах профессиональных специалисты им проходят международной бизнесе 12 каждого всех компания аттестацию бухгалтерского бухгалтер изменений', '/portfolio/osprof', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 33, 'ru', 'ООО «Энергоконсультант»', 'ООО «Энергоконсультант» осуществляет деятельность по техническому контролю, испытаниям и анализу; научные исследования и разработки в области естественных и технических наук; разработку пр...', 'образования учреждениях образовательных испытаниям программного энергоконсультант высшее осуществляет по квалификации для в исследования разработки профессиональное разработку научные технических профессионального образование повышения техническому и этой имеющих анализу естественных деятельность специалистов консультирование обучение ооо области обеспечения контролю наук дополнительного', '/portfolio/energocon', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 34, 'ru', 'Московская городская служба бронирования ООО «Отель Экспресс Компани»', 'На сайте вы можете ознакомиться с гостиницами, увидеть фото номеров, подобрать отель под свой бюджет, а также получить краткую справочную информацию о городе, его населении, административной принадле...', 'увидеть городе под ознакомиться поясе также городская его административной информацию коде часовом получить а служба номеров принадлежности населении вы подобрать московская достопримечательностях о на и с бюджет справочную отель сайте телефоном фото гостиницами бронирования можете ооо компани свой экспресс краткую', '/portfolio/exh', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 35, 'ru', 'Система он-лайн публикации газеты «Вакансия»', 'Газета «Вакансия от А до Я» выходит в Москве, Санкт-Петербурге и Екатеринбурге.', 'выходит до публикации вакансия и санкт-петербурге я от в москве а газеты газета система он-лайн екатеринбурге', '/portfolio/vak', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 36, 'ru', 'Сайт компании «АвтоДиК»', 'АвтоДиК готов всегда помочь решить проблемы с вашим автомобилем. Основные виды деятельности: покупка битых автомобилей, неисправных или требующих утилизации, выкуп аварийных авто; разборка иномарок и...', 'запчастей вашим автомобилей автодик всегда проблемы эвакуатора автомобиля автомобиль автомобилем разборка авто аварийных готов иномарок неисправных сайт требующих отечественных компании помочь когда битых деятельности на и не с бу эвакуация покупка виды выкуп или предоставление продажа ходу основные утилизации решить', '/portfolio/razborka', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 37, 'ru', 'Сайт компании «Лес тут»', 'Компания 10 лет занимается деревянным домостроением. Кировские мастера изготавливают самые лучшие срубы деревянных домов и коттеджей из высококачественного бревна, также срубы деревянных бань и беседо...', 'собственное плотников мастера из срубы самого также кировские свои в домов лет бань производство беседок лес делянки занимается сайт 10 свое бревна компании тут бригады строительного лучшего материала и самые деревянных домостроением кировской компания деревянным коттеджей высококачественного кировских области дерева монтажников изготавливают лучшие', '/portfolio/lestut', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 38, 'ru', 'Электронная гуманитарная библиотека E-Lingvo.net', 'E-Lingvo.net — крупнейшая в российском сегменте Интернета гуманитарная он-лайн библиотека. Здесь Вы найдете научные статьи и исследования известных филологов и литературоведов на английском, немецком,...', 'филологов французском e-lingvonet известных также языках пособия электронная в исследования а литературоведов многое гуманитарная научные немецком вы библиотека на сегменте крупнейшая и здесь других шпаргалки учебные английском статьи интернета российском найдете другое он-лайн лекции', '/portfolio/e-lingvo', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 39, 'ru', 'Сайт группы «Маркшейдер кунст»', '«Маркше́йдер Ку́нст» (нем. Markscheider — «горный инженер», Kunst — «искусство») — музыкальная группа, образованная в 1992 году студентами-геологами в Санкт-Петербурге. В начале предпочтение отдавалос...', 'группа стали ку́нст элементы начале блюза санкт-петербурге году в этнические маркше́йдер рокабилли отчётливее искусство а латино kunst жёсткого нем сайт позже предпочтение маркшейдер markscheider горный кунст но и творчестве все группы потом появляться стилю мотивы студентами-геологами ямайские музыкальная образованная отдавалось 1992 инженер', '/portfolio/mkunst', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 40, 'ru', 'Сайт компании «Улов 10 тонн»', 'Компания предоставляет услуги по бронированию рыболовных баз на территории России.', 'россии рыболовных услуги по компания на предоставляет улов бронированию сайт баз 10 тонн территории компании', '/portfolio/ulov100', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 41, 'ru', 'Сайт фотографа Константина Шутова', 'Как профессиональный фотограф Константин Шутов занимается различными видами фоторабот, среди которых интерьерная, ландшафтная фотография, съёмка в студии, предметная и портретная фотосъемка, портфолио...', 'различными студии свадебная фоторабот фотография как работа фотограф в репортаж предметная среди сайт занимается портретная шутова шутов и фотографа константин профессиональный выездная портфолио различного константина которых рода видами фотосъемка ландшафтная интерьерная съёмка', '/portfolio/fotokost', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 42, 'ru', 'Сайт компании KS Motors', 'Компания KS Motors — одна из крупенйших компаний на рынке Санкт-Петербурга, специализирующаяся на продаже подержанных автомобилей из США, Канады и Германии. Приобретая автомобиль в KS Motors, Вы может...', 'уверены ks растаможкой тд представленных из по автомобилей также опыт покупку в выгодную рынке автомобиля автомобиль ценам том быть продаже сайт связанных санкт-петербурга услуг вы компании неделю дополнительных сша ряд низким германии регистрацией поставку одна на и с что гарантирует компаний крупенйших motors сайте срок совершаете подержанных раз несколько компания можете канады качественную приобретая пополняется самым каталог специализирующаяся предоставляется', '/portfolio/ksmotors', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 43, 'ru', 'Аренда квартир «Арендадел»', 'На сайте «Арендадел» вы можете снять и сдать квартиру жилье без посредников, во всех городах России. Подключена платежная система, гибкие возможности администрирования, лакончиный дизайн.', 'россии городах посредников квартир возможности во жилье снять на платежная и сдать гибкие администрирования сайте лакончиный дизайн арендадел подключена можете всех без система аренда вы квартиру', '/portfolio/arendadel', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 44, 'ru', 'Промо-материалы и фирменный стиль кафе «Циник»', 'Легендарное треш-бар-кафе «Циник»', 'циник промо-материалы и стиль фирменный легендарное треш-бар-кафе кафе', '/portfolio/cynic_style', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 45, 'ru', 'Система учета для компании KS Motors', 'Компания KS Motors — одна из крупенйших компаний на рынке Санкт-Петербурга, специализирующаяся на продаже подержанных автомобилей из США, Канады и Германии.', 'ks сша германии из автомобилей на одна и учета компаний крупенйших motors для рынке подержанных компания канады продаже система специализирующаяся санкт-петербурга компании', '/portfolio/ksdb', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 46, 'ru', 'Учет расходов KS Motors', 'Компания KS Motors — одна из крупенйших компаний на рынке Санкт-Петербурга, специализирующаяся на продаже подержанных автомобилей из США, Канады и Германии.', 'ks сша германии из автомобилей на одна учет и компаний крупенйших расходов motors рынке подержанных компания канады продаже специализирующаяся санкт-петербурга', '/portfolio/ksacc', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 47, 'ru', 'HTML Generator', 'HTML Generator - это программа для удобного и легкого создания страничек для вашего сайта! С её помощью вы сможете выбрать любой стиль страницы или создать собственный, задать любые настройки, размест...', 'работе тд учебников вам activex разместить generator поставляется удобного помогут русского легкого в сайта для поможет освоить интернет сможете страничек dynamic задать любые полезных другого вашего мастер работы собственный программой интересных вы которые это программа любой помощью настройки и - с html поддержка создать созданные страницы или много java perl стиль начала создания её выбрать', '/portfolio/hg', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 48, 'ru', 'Color Lines', 'Color Lines - увлекательная логическая игра для вашего Android-устройства. Она абсолютно бесплатна, и в ней отсутствует реклама!Особенности данной версии:- Поддержка графики Full HD (до 1920...', 'рекламаособенности windows до абсолютно переключение бесплатна как игры в для звук- hd комфортной 1920x1980- графики различных full же четыре вашего игра отсутствует увлекательная оригинальной android-устройства так версии- lines - и color логическая ней данной поддержка она игровых режимов день-ночь оригинальная графика mobile-версии- режима', '/portfolio/colorlines', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 49, 'ru', 'Кинг', 'Кинг – карточная игра, популярная в России. Иногда ее называют «дамским преферансом». Во Франции есть похожая карточная игра Barbu (фр. «Борода»).Особенности текущей верси...', 'россии многопользовательской до франции популярная по разрешения похожая есть игры в ренессанс текущей 1920x1080- hd full различные дамским игра wi-fi кинг преферансом во версии- иногда называют и скат- поддержка ее фр бородаособенности barbu карточная карт колоды атласные', '/portfolio/king', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 50, 'ru', 'Bubble Breaker', 'Bubble Breaker - увлекательная логическая игра для вашего Android-устройства. Она абсолютно бесплатна, и в ней отсутствует реклама!Особенности данной версии:- Поддержка графики Full HD (до 1...', 'рекламаособенности breaker windows до абсолютно переключение бесплатна как игры в для звук- hd комфортной 1920x1980- графики различных full же четыре вашего игра отсутствует увлекательная оригинальной android-устройства так версии- - и логическая ней данной поддержка она игровых режимов день-ночь оригинальная графика bubble mobile-версии- режима', '/portfolio/bubblebreaker', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('portfolio', 51, 'ru', 'Девятка', 'Девятка - захватывающая карточная игра.Особенности текущей версии:- Поддержка Full HD разрешения (до 1920x1080)- Различные колоды карт («атласные», «ренессанс» и...', 'многопользовательской захватывающая до версии- по разрешения и - скат- девятка поддержка игры играособенности ренессанс текущей 1920x1080- карточная hd full различные карт колоды wi-fi атласные', '/portfolio/nine', 1379321279);
INSERT INTO `taracot_search_db` VALUES ('catalog', 1, 'en', 'Test item', 'OK Computer', 'ok test item computer', '/', 1380886960);

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
) ENGINE=MyISAM AUTO_INCREMENT=20 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=20 ;

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
INSERT INTO `taracot_settings` VALUES (17, 'support_topics', 'hosting,Hosting problem;design,Web design question;billing,Billing questions;account,My Account', '', 'en', 1379674523);
INSERT INTO `taracot_settings` VALUES (18, 'support_mail', 'billing=xtreme@re-hash.ru, billing@re-hash.ru;hosting=hosting@rh1.ru;all=all@rh1.ru', '', '', 1378123809);
INSERT INTO `taracot_settings` VALUES (19, 'feedback_email', 'xtreme@rh1.ru', '', 'en', 1380205178);

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
INSERT INTO `taracot_support` VALUES (10, 'user', 1379680129, 'design', 'Ни хрена не работает', 'И какого, спрашивается, чорта?<br />\n<br />\n<img src="http://i.blog.fontanka.ru/photos/2013/09/220x220_dLR16SGX1B1HXZ7i9TV9.jpg" width="90" height="60" alt="" border="0" /> ', 0, 1, 'user', '4d3dfa98e0243018e85ef48dc93ddeab', 1379680182);
INSERT INTO `taracot_support` VALUES (11, 'xtreme', 1378123597, 'hosting', 'OK', 'Hellow', 0, 0, 'xtreme', '0547bca99c4c06f4f614514e3bd2b4e7', NULL);
INSERT INTO `taracot_support` VALUES (12, 'xtreme', 1378123699, 'hosting', 'OK Computer', 'Helloooow', 0, 0, 'xtreme', '8ddbecace17618bc4942cb3a54c34e3e', NULL);
INSERT INTO `taracot_support` VALUES (13, 'xtreme', 1378123720, 'billing', 'Yep', 'yep', 0, 0, 'xtreme', '9348ae7851cf3ba798d9564ef308ec25', NULL);
INSERT INTO `taracot_support` VALUES (14, 'xtreme', 1378123877, 'hosting', 'OK All', 'yeeeep', 0, 0, 'xtreme', 'e7fbd5c08a4fbec53bff0ff5ba49fc07', NULL);
INSERT INTO `taracot_support` VALUES (15, 'xtreme', 1378123908, 'hosting', 'Another one', 'Hey hey hey', 0, 0, 'xtreme', '7fc8d5ba5078256a5280aba339cbb0b0', NULL);
INSERT INTO `taracot_support` VALUES (16, 'xtreme', 1378123936, 'hosting', 'd2', 'd2', 0, 0, 'xtreme', 'b25b0651e4b6e887e5194135d3692631', NULL);
INSERT INTO `taracot_support` VALUES (17, 'xtreme', 1378123951, 'billing', 'BQ', 'BBQ', 0, 0, 'xtreme', '709cf76964bf6b2149e7a8040fa24cf5', 1379931647);
INSERT INTO `taracot_support` VALUES (18, 'xtreme', 1378125358, 'design', 'WDQ', 'WDQ', 0, 0, 'xtreme', '58afb946581d678ab24c42be9a309cda', 1379931644);

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
) ENGINE=MyISAM AUTO_INCREMENT=43 DEFAULT CHARSET=utf8 AUTO_INCREMENT=43 ;

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
INSERT INTO `taracot_support_ans` VALUES (34, 10, 'user', 1379677326, 'Тест.', '35c07b0445bba8d5035d56b98995de32');
INSERT INTO `taracot_support_ans` VALUES (35, 10, 'user', 1379677334, 'Ну чуваааааааак, как это - не работает?!! Ну чуваааааааак, как это - не работает?!!<br />\n', '2ed10c9ccc915f823bb68ae06edc8fd2');
INSERT INTO `taracot_support_ans` VALUES (36, 10, 'user', 1379677344, 'Как бы мне отловить этот факин юникод глюк', 'ec920dc26da3fc0ccb7ac98cda23465f');
INSERT INTO `taracot_support_ans` VALUES (37, 10, 'user', 1379677899, 'Тут однозначно русский текст', 'f63ab1fe29b9ad09ede0f28af62e98a1');
INSERT INTO `taracot_support_ans` VALUES (38, 10, 'user', 1379677905, 'А тут hren poymesh', '052fad875dde1e1eaba13bcaea6488fb');
INSERT INTO `taracot_support_ans` VALUES (39, 10, 'user', 1379677922, 'Что за&nbsp;фигня&nbsp;&mdash; стоит мне только ввести короткий русский текст, как&nbsp;он не&nbsp;определяется, как&nbsp;русский', 'a6c6f41eec6e48d72b1b25109f29a06d');
INSERT INTO `taracot_support_ans` VALUES (40, 10, 'user', 1379677967, 'Ð¢ÐµÐ¼ Ð½Ðµ&nbsp;Ð¼ÐµÐ½ÐµÐµ, ÑÐ¶Ðµ Ð½Ð°&nbsp;Ð½Ð°ÑÐ°Ð»ÑÐ½Ð¾Ð¼ ÑÑÐ°Ð¿Ðµ Ð¼Ð¾Ð¶Ð½Ð¾ Ð¿ÑÐ¸Ð¼ÐµÑÐ½Ð¾ ÑÐ¾ÑÑÐ°Ð²Ð¸ÑÑ ÑÐ¼ÐµÑÑ ÑÐ°Ð·ÑÐ°Ð±Ð¾ÑÐºÐ¸ Ð¿ÑÐ¾ÐµÐºÑÐ°. Ð­ÑÐ¾ ÑÑÐ°Ð½Ð¾Ð²Ð¸ÑÑÑ Ð²Ð¾Ð·Ð¼Ð¾Ð¶Ð½ÑÐ¼ Ð·Ð°&nbsp;ÑÑÐµÑ ÑÐ¾Ð³Ð¾, ÑÑÐ¾ \nÑÐ°Ð·ÑÐ°Ð±Ð°ÑÑÐ²Ð°ÐµÐ¼Ð¾Ðµ Ð½Ð°Ð¼Ð¸ Ð¿ÑÐ¾Ð³ÑÐ°Ð¼Ð¼Ð½Ð¾Ðµ Ð¾Ð±ÐµÑÐ¿ÐµÑÐµÐ½Ð¸Ðµ Ð¸Ð¼ÐµÐµÑ Ð¼Ð¾Ð´ÑÐ»ÑÐ½ÑÑ ÑÑÑÑÐºÑÑÑÑ, \nÑ.Ðµ. ÐÑ Ð¿Ð¾Ð´ÐºÐ»ÑÑÐ°ÐµÑÐµ Ðº&nbsp;ÐÐ°ÑÐµÐ¼Ñ ÑÐ°Ð¹ÑÑ ÑÐ¾Ð»ÑÐºÐ¾ ÑÐµ ÑÑÐ½ÐºÑÐ¸Ð¸, ÐºÐ¾ÑÐ¾ÑÑÐµ Ð²Ð°Ð¼ \nÐ½ÐµÐ¾Ð±ÑÐ¾Ð´Ð¸Ð¼Ñ.', '1443daccbbfe2c082d36f341d747eeb0');
INSERT INTO `taracot_support_ans` VALUES (41, 10, 'user', 1379677987, 'Тем не&nbsp;менее, уже на&nbsp;начальном этапе можно примерно составить смету разработки проекта. Это становится возможным за&nbsp;счет того, что \nразрабатываемое нами программное обеспечение имеет модульную структуру, \nт.е. Вы подключаете к&nbsp;Вашему сайту только те функции, которые вам \nнеобходимы.', '25e82a578a054a384cf990bd2e6cae2b');
INSERT INTO `taracot_support_ans` VALUES (42, 10, 'user', 1379680129, '<img src="http://habr.habrastorage.org/post_images/710/101/bca/710101bcaf13c69d4189dafb53165f01.gif" width="90" height="60" alt="" border="0" /> ', '9484cad0762d33a4feec2e39bad79423');

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

INSERT INTO `taracot_users` VALUES (1, 'xtreme', '0f5559ee359fba749e7e6638fcfdbbfb', 0, 'Michael Matveev', '', NULL, NULL, '79217998111', 'blog_post, blog_moderator, blog_moderator_test1', 2, NULL, 1376300791, 'en', 0, 0, 1379675238);
INSERT INTO `taracot_users` VALUES (2, 'user', '1d88c84caa93404ecf250399bc1be5a0', 1, 'John Doe', '', NULL, NULL, '79217998111', '', 1, NULL, NULL, 'en', 1376731887, 0, 1379770337);
