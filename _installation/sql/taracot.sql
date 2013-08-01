-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Aug 01, 2013 at 08:00 PM
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
) ENGINE=MyISAM AUTO_INCREMENT=59 DEFAULT CHARSET=utf8 AUTO_INCREMENT=59 ;

-- 
-- Dumping data for table `taracot_billing_bills`
-- 

INSERT INTO `taracot_billing_bills` VALUES (38, 1, 12, 1355394567);
INSERT INTO `taracot_billing_bills` VALUES (3, 1, 12, 1355324166);
INSERT INTO `taracot_billing_bills` VALUES (4, 1, 12, 1355324224);
INSERT INTO `taracot_billing_bills` VALUES (5, 1, 12, 1355324375);
INSERT INTO `taracot_billing_bills` VALUES (6, 1, 12, 1355324414);
INSERT INTO `taracot_billing_bills` VALUES (7, 1, 12, 1355384698);
INSERT INTO `taracot_billing_bills` VALUES (8, 1, 12, 1355384715);
INSERT INTO `taracot_billing_bills` VALUES (9, 1, 12, 1355385157);
INSERT INTO `taracot_billing_bills` VALUES (10, 1, 12.95, 1355385332);
INSERT INTO `taracot_billing_bills` VALUES (11, 1, 12.95, 1355385457);
INSERT INTO `taracot_billing_bills` VALUES (12, 1, 12.95, 1355385470);
INSERT INTO `taracot_billing_bills` VALUES (13, 1, 12.95, 1355385488);
INSERT INTO `taracot_billing_bills` VALUES (14, 1, 12.95, 1355385875);
INSERT INTO `taracot_billing_bills` VALUES (15, 1, 12.95, 1355385889);
INSERT INTO `taracot_billing_bills` VALUES (16, 1, 12.95, 1355385910);
INSERT INTO `taracot_billing_bills` VALUES (17, 1, 12.95, 1355385919);
INSERT INTO `taracot_billing_bills` VALUES (18, 1, 1, 1355385930);
INSERT INTO `taracot_billing_bills` VALUES (19, 1, 1, 1355385959);
INSERT INTO `taracot_billing_bills` VALUES (20, 1, 12, 1355386060);
INSERT INTO `taracot_billing_bills` VALUES (21, 1, 1212, 1355386100);
INSERT INTO `taracot_billing_bills` VALUES (22, 1, 12, 1355386113);
INSERT INTO `taracot_billing_bills` VALUES (23, 1, 12, 1355386302);
INSERT INTO `taracot_billing_bills` VALUES (24, 1, 12, 1355386309);
INSERT INTO `taracot_billing_bills` VALUES (25, 1, 456, 1355386319);
INSERT INTO `taracot_billing_bills` VALUES (26, 1, 134, 1355386431);
INSERT INTO `taracot_billing_bills` VALUES (27, 1, 134, 1355386442);
INSERT INTO `taracot_billing_bills` VALUES (28, 1, 111, 1355386450);
INSERT INTO `taracot_billing_bills` VALUES (29, 1, 111, 1355386533);
INSERT INTO `taracot_billing_bills` VALUES (30, 1, 111, 1355386591);
INSERT INTO `taracot_billing_bills` VALUES (31, 1, 12, 1355386596);
INSERT INTO `taracot_billing_bills` VALUES (32, 1, 12, 1355386622);
INSERT INTO `taracot_billing_bills` VALUES (33, 1, 12, 1355386629);
INSERT INTO `taracot_billing_bills` VALUES (34, 1, 12, 1355386632);
INSERT INTO `taracot_billing_bills` VALUES (35, 1, 12, 1355387138);
INSERT INTO `taracot_billing_bills` VALUES (36, 1, 12, 1355387860);
INSERT INTO `taracot_billing_bills` VALUES (37, 1, 12, 1355387867);
INSERT INTO `taracot_billing_bills` VALUES (39, 1, 1, 1355606394);
INSERT INTO `taracot_billing_bills` VALUES (40, 1, 1, 1355606726);
INSERT INTO `taracot_billing_bills` VALUES (41, 1, 12, 1356011069);
INSERT INTO `taracot_billing_bills` VALUES (42, 1, 12, 1356520719);
INSERT INTO `taracot_billing_bills` VALUES (43, 1, 1234, 1356596496);
INSERT INTO `taracot_billing_bills` VALUES (44, 1, 12, 1356596521);
INSERT INTO `taracot_billing_bills` VALUES (45, 1, 123, 1356596562);
INSERT INTO `taracot_billing_bills` VALUES (46, 1, 123, 1356596570);
INSERT INTO `taracot_billing_bills` VALUES (47, 1, 123, 1356596615);
INSERT INTO `taracot_billing_bills` VALUES (48, 1, 12, 1356596634);
INSERT INTO `taracot_billing_bills` VALUES (49, 1, 12, 1356596654);
INSERT INTO `taracot_billing_bills` VALUES (50, 1, 1212, 1356596947);
INSERT INTO `taracot_billing_bills` VALUES (51, 1, 12, 1356603145);
INSERT INTO `taracot_billing_bills` VALUES (52, 1, 12, 1356606732);
INSERT INTO `taracot_billing_bills` VALUES (53, 1, 12, 1356606748);
INSERT INTO `taracot_billing_bills` VALUES (54, 1, 12, 1356606793);
INSERT INTO `taracot_billing_bills` VALUES (55, 1, 12, 1356606812);
INSERT INTO `taracot_billing_bills` VALUES (56, 1, 12, 1356608800);
INSERT INTO `taracot_billing_bills` VALUES (57, 1, 120, 1356975676);
INSERT INTO `taracot_billing_bills` VALUES (58, 1, 12, 1357645304);

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
) ENGINE=MyISAM AUTO_INCREMENT=68 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=43 AUTO_INCREMENT=68 ;

-- 
-- Dumping data for table `taracot_billing_domains`
-- 

INSERT INTO `taracot_billing_domains` VALUES (67, 1, 'test2.com', 1357848000, '', 'ns1.re-hash.org', 'ns2.re-hash.org', '', '', '', '', '', '', '127.0.0.1', 1, 1357677091);
INSERT INTO `taracot_billing_domains` VALUES (66, 1, 'test.com', 1357934400, '', 'ns1.re-hash.org', 'ns2.re-hash.org', '', '', '', '', '', '', '127.0.0.1', 1, 1357676913);

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
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=17 AUTO_INCREMENT=4 ;

-- 
-- Dumping data for table `taracot_billing_funds`
-- 

INSERT INTO `taracot_billing_funds` VALUES (1, 1, 249285, 1357664012);
INSERT INTO `taracot_billing_funds` VALUES (3, 9, 108806, 1357143392);

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
) ENGINE=MyISAM AUTO_INCREMENT=257 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=60 AUTO_INCREMENT=257 ;

-- 
-- Dumping data for table `taracot_billing_funds_history`
-- 

INSERT INTO `taracot_billing_funds_history` VALUES (12, 1, 'addfunds', 'Webmoney', 12, 1355393580, 1355393580);
INSERT INTO `taracot_billing_funds_history` VALUES (13, 1, 'addfunds', 'Robokassa', 12, 1355394530, 1355394530);
INSERT INTO `taracot_billing_funds_history` VALUES (9, 1, '', 'Test', 100, 1354630500, 1354629686);
INSERT INTO `taracot_billing_funds_history` VALUES (6, 1, 'domainregister', 'microsoft.com', 666, 1354614300, 1354616483);
INSERT INTO `taracot_billing_funds_history` VALUES (8, 9, 'domainupdate', 'test.ru', 1234, 1354625100, 1354625568);
INSERT INTO `taracot_billing_funds_history` VALUES (14, 1, 'hostingupdate', 'test', 199, 1355650422, 1355650422);
INSERT INTO `taracot_billing_funds_history` VALUES (15, 1, 'hostingupdate', 'medved', 597, 1355655803, 1355655803);
INSERT INTO `taracot_billing_funds_history` VALUES (16, 1, 'hostingupdate', 'medved', 199, 1355655851, 1355655851);
INSERT INTO `taracot_billing_funds_history` VALUES (17, 1, 'hostingupdate', 'medved', -199, 1355655920, 1355655920);
INSERT INTO `taracot_billing_funds_history` VALUES (18, 1, 'hostingregister', 'okokok', -199, 1355686432, 1355686432);
INSERT INTO `taracot_billing_funds_history` VALUES (19, 1, 'hostingregister', 'ours', -199, 1355687074, 1355687074);
INSERT INTO `taracot_billing_funds_history` VALUES (20, 1, 'hostingregister', 'ours', -199, 1355687320, 1355687320);
INSERT INTO `taracot_billing_funds_history` VALUES (21, 1, 'hostingupdate', 'ours', -398, 1355687624, 1355687624);
INSERT INTO `taracot_billing_funds_history` VALUES (22, 1, 'hostingupdate', 'medved', -199, 1355734227, 1355734227);
INSERT INTO `taracot_billing_funds_history` VALUES (23, 1, 'hostingupdate', 'ours', -199, 1355746547, 1355746547);
INSERT INTO `taracot_billing_funds_history` VALUES (24, 1, 'hostingupdate', 'medved', -199, 1355751248, 1355751248);
INSERT INTO `taracot_billing_funds_history` VALUES (25, 1, 'hostingupdate', 'ours', -199, 1355751251, 1355751251);
INSERT INTO `taracot_billing_funds_history` VALUES (26, 1, 'hostingupdate', 'medved', -199, 1355755238, 1355755238);
INSERT INTO `taracot_billing_funds_history` VALUES (27, 1, 'hostingupdate', 'ours', -199, 1355755241, 1355755241);
INSERT INTO `taracot_billing_funds_history` VALUES (28, 1, 'hostingupdate', 'ours', -199, 1355755358, 1355755358);
INSERT INTO `taracot_billing_funds_history` VALUES (29, 1, 'hostingupdate', 'ours', -199, 1355755418, 1355755418);
INSERT INTO `taracot_billing_funds_history` VALUES (30, 1, 'hostingupdate', 'ours', -199, 1355755513, 1355755513);
INSERT INTO `taracot_billing_funds_history` VALUES (31, 1, 'hostingupdate', 'medved', -199, 1355829179, 1355829179);
INSERT INTO `taracot_billing_funds_history` VALUES (32, 1, 'hostingregister', 'test', -199, 1355829672, 1355829672);
INSERT INTO `taracot_billing_funds_history` VALUES (33, 1, 'hostingupdate', 'ours', -199, 1355830121, 1355830121);
INSERT INTO `taracot_billing_funds_history` VALUES (34, 1, 'hostingupdate', 'ours', -199, 1355830198, 1355830198);
INSERT INTO `taracot_billing_funds_history` VALUES (35, 1, 'hostingregister', 'test', -199, 1355834164, 1355834164);
INSERT INTO `taracot_billing_funds_history` VALUES (36, 1, 'hostingupdate', 'medved', -199, 1355908936, 1355908936);
INSERT INTO `taracot_billing_funds_history` VALUES (37, 1, 'domainregister', 'microsoft.ru', -500, 1355929025, 1355929025);
INSERT INTO `taracot_billing_funds_history` VALUES (38, 1, 'domainregister', 'ms2.com', -500, 1355929105, 1355929105);
INSERT INTO `taracot_billing_funds_history` VALUES (39, 1, 'domainregister', 'test.com', -500, 1356440208, 1356440208);
INSERT INTO `taracot_billing_funds_history` VALUES (40, 1, 'hostingupdate', 'medved', -199, 1356440799, 1356440799);
INSERT INTO `taracot_billing_funds_history` VALUES (41, 1, 'hostingupdate', 'medved', -199, 1356440998, 1356440998);
INSERT INTO `taracot_billing_funds_history` VALUES (42, 1, 'domainupdate', 'domain.com', -500, 1356444979, 1356444979);
INSERT INTO `taracot_billing_funds_history` VALUES (43, 1, 'domainupdate', 'test.com', -500, 1356445437, 1356445437);
INSERT INTO `taracot_billing_funds_history` VALUES (44, 1, 'domainupdate', 'domain.com', -500, 1356445819, 1356445819);
INSERT INTO `taracot_billing_funds_history` VALUES (45, 1, 'domainupdate', 'domain.ru', -400, 1356446183, 1356446183);
INSERT INTO `taracot_billing_funds_history` VALUES (46, 1, 'domainupdate', 'domain.com', -500, 1356514333, 1356514333);
INSERT INTO `taracot_billing_funds_history` VALUES (47, 1, 'hostingupdate', 'medved', -199, 1356514341, 1356514341);
INSERT INTO `taracot_billing_funds_history` VALUES (48, 1, 'hostingregister', 'ours2', -199, 1356514604, 1356514604);
INSERT INTO `taracot_billing_funds_history` VALUES (49, 1, 'hostingregister', 'ours3', -199, 1356515129, 1356515129);
INSERT INTO `taracot_billing_funds_history` VALUES (50, 1, 'hostingregister', 'ours4', -199, 1356515171, 1356515171);
INSERT INTO `taracot_billing_funds_history` VALUES (51, 1, 'hostingregister', 'ours5', -199, 1356515364, 1356515364);
INSERT INTO `taracot_billing_funds_history` VALUES (52, 1, 'hostingregister', 'ours6', -199, 1356515462, 1356515462);
INSERT INTO `taracot_billing_funds_history` VALUES (53, 1, 'hostingregister', 'ours7', -199, 1356515489, 1356515489);
INSERT INTO `taracot_billing_funds_history` VALUES (54, 1, 'hostingregister', 'ours8', -199, 1356515520, 1356515520);
INSERT INTO `taracot_billing_funds_history` VALUES (55, 1, 'hostingregister', 'ours9', -199, 1356515573, 1356515573);
INSERT INTO `taracot_billing_funds_history` VALUES (56, 1, 'hostingupdate', 'ours2', -199, 1356515601, 1356515601);
INSERT INTO `taracot_billing_funds_history` VALUES (57, 1, 'hostingupdate', 'ours3', -199, 1356515613, 1356515613);
INSERT INTO `taracot_billing_funds_history` VALUES (58, 1, 'hostingupdate', 'test', -199, 1356515735, 1356515735);
INSERT INTO `taracot_billing_funds_history` VALUES (59, 1, 'hostingupdate', 'medved', -199, 1356515753, 1356515753);
INSERT INTO `taracot_billing_funds_history` VALUES (60, 1, 'hostingupdate', 'medved', -199, 1356515789, 1356515789);
INSERT INTO `taracot_billing_funds_history` VALUES (61, 1, 'hostingupdate', 'medved', -199, 1356515817, 1356515817);
INSERT INTO `taracot_billing_funds_history` VALUES (62, 1, 'hostingupdate', 'medved', -199, 1356515863, 1356515863);
INSERT INTO `taracot_billing_funds_history` VALUES (63, 1, 'hostingupdate', 'medved', -199, 1356515957, 1356515957);
INSERT INTO `taracot_billing_funds_history` VALUES (64, 1, 'hostingupdate', 'medved', -199, 1356515973, 1356515973);
INSERT INTO `taracot_billing_funds_history` VALUES (65, 1, 'hostingupdate', 'medved', -199, 1356516011, 1356516011);
INSERT INTO `taracot_billing_funds_history` VALUES (66, 1, 'hostingupdate', 'medved', -199, 1356516021, 1356516021);
INSERT INTO `taracot_billing_funds_history` VALUES (67, 1, 'hostingupdate', 'medved', -199, 1356516048, 1356516048);
INSERT INTO `taracot_billing_funds_history` VALUES (68, 1, 'hostingupdate', 'medved', -199, 1356516062, 1356516062);
INSERT INTO `taracot_billing_funds_history` VALUES (69, 1, 'hostingregister', 'ours10', -199, 1356517212, 1356517212);
INSERT INTO `taracot_billing_funds_history` VALUES (70, 1, 'hostingupdate', 'medved', -199, 1356517220, 1356517220);
INSERT INTO `taracot_billing_funds_history` VALUES (71, 1, 'domainupdate', 'domain.com', -500, 1356517229, 1356517229);
INSERT INTO `taracot_billing_funds_history` VALUES (72, 1, 'domainupdate', 'domain.com', -500, 1356517237, 1356517237);
INSERT INTO `taracot_billing_funds_history` VALUES (73, 1, 'domainupdate', 'domain.com', -500, 1356517243, 1356517243);
INSERT INTO `taracot_billing_funds_history` VALUES (74, 1, 'domainregister', 'domain2.com', -500, 1356517258, 1356517258);
INSERT INTO `taracot_billing_funds_history` VALUES (75, 1, 'serviceupdate', 'backup', -666, 1356598428, 1356598428);
INSERT INTO `taracot_billing_funds_history` VALUES (76, 1, 'serviceupdate', 'backup', -666, 1356603084, 1356603084);
INSERT INTO `taracot_billing_funds_history` VALUES (77, 1, 'serviceupdate', 'backup', -666, 1356603139, 1356603139);
INSERT INTO `taracot_billing_funds_history` VALUES (78, 1, 'serviceupdate', 'backup', -666, 1356603450, 1356603450);
INSERT INTO `taracot_billing_funds_history` VALUES (79, 1, 'domainregister', 'medved.com', -500, 1356606599, 1356606599);
INSERT INTO `taracot_billing_funds_history` VALUES (80, 1, 'domainupdate', 'medved.com', -500, 1356606887, 1356606887);
INSERT INTO `taracot_billing_funds_history` VALUES (81, 1, 'hostingregister', 'oursik', -199, 1356695529, 1356695529);
INSERT INTO `taracot_billing_funds_history` VALUES (82, 1, 'hostingregister', 'mdvd', -199, 1356701710, 1356701710);
INSERT INTO `taracot_billing_funds_history` VALUES (83, 1, 'hostingupdate', 'ours', -199, 1356702408, 1356702408);
INSERT INTO `taracot_billing_funds_history` VALUES (84, 1, 'hostingupdate', 'mdvd', -199, 1356702421, 1356702421);
INSERT INTO `taracot_billing_funds_history` VALUES (85, 1, 'hostingregister', 'mdvd2', -199, 1356704993, 1356704993);
INSERT INTO `taracot_billing_funds_history` VALUES (86, 1, 'hostingregister', 'whops', -199, 1356706061, 1356706061);
INSERT INTO `taracot_billing_funds_history` VALUES (87, 1, 'fundsrefund', 'Error while creating new user account - mdvd2', 199, 1356901443, 1356901443);
INSERT INTO `taracot_billing_funds_history` VALUES (88, 9, 'hostingregister', 'test', -199, 1357120805, 1357120805);
INSERT INTO `taracot_billing_funds_history` VALUES (89, 1, 'fundsrefund', 'Error while creating new user account - whops', 199, 1357120888, 1357120888);
INSERT INTO `taracot_billing_funds_history` VALUES (90, 9, 'fundsrefund', 'Error while creating new user account - test', 199, 1357120930, 1357120930);
INSERT INTO `taracot_billing_funds_history` VALUES (91, 9, 'hostingregister', 'test', -199, 1357126403, 1357126403);
INSERT INTO `taracot_billing_funds_history` VALUES (92, 1, 'hostingregister', 'test', -199, 1357139192, 1357139192);
INSERT INTO `taracot_billing_funds_history` VALUES (93, 9, 'hostingregister', 'test1', -199, 1357139682, 1357139682);
INSERT INTO `taracot_billing_funds_history` VALUES (94, 9, 'hostingregister', 'test1', -199, 1357139858, 1357139858);
INSERT INTO `taracot_billing_funds_history` VALUES (95, 9, 'hostingregister', 'test1', -199, 1357140622, 1357140622);
INSERT INTO `taracot_billing_funds_history` VALUES (96, 9, 'hostingregister', 'test1', -199, 1357143392, 1357143392);
INSERT INTO `taracot_billing_funds_history` VALUES (97, 1, 'domainupdate', 'medved.com', -500, 1357145651, 1357145651);
INSERT INTO `taracot_billing_funds_history` VALUES (98, 1, 'domainupdate', 'medved.com', -500, 1357146089, 1357146089);
INSERT INTO `taracot_billing_funds_history` VALUES (99, 1, 'domainregister', 'r2e2.com', -500, 1357162970, 1357162970);
INSERT INTO `taracot_billing_funds_history` VALUES (100, 1, 'domainregister', 'test.com', -500, 1357163602, 1357163602);
INSERT INTO `taracot_billing_funds_history` VALUES (101, 1, 'domainregister', 'test.com', -500, 1357163663, 1357163663);
INSERT INTO `taracot_billing_funds_history` VALUES (102, 1, 'domainregister', 'test.ru', -500, 1357165985, 1357165985);
INSERT INTO `taracot_billing_funds_history` VALUES (103, 1, 'domainregister', 'petitours.com', -500, 1357168325, 1357168325);
INSERT INTO `taracot_billing_funds_history` VALUES (104, 1, 'domainregister', 'test1.com', -500, 1357327177, 1357327177);
INSERT INTO `taracot_billing_funds_history` VALUES (105, 1, 'refund', 'Error while registering the domain - petitours.com', 500, 1357328202, 1357328202);
INSERT INTO `taracot_billing_funds_history` VALUES (106, 1, 'refund', 'Error while registering the domain - test1.com', 500, 1357328544, 1357328544);
INSERT INTO `taracot_billing_funds_history` VALUES (107, 1, 'domainregister', 'test2.ru', -500, 1357329242, 1357329242);
INSERT INTO `taracot_billing_funds_history` VALUES (108, 1, 'refund', 'Error while registering the domain - test2.ru', 500, 1357329260, 1357329260);
INSERT INTO `taracot_billing_funds_history` VALUES (109, 1, 'domainregister', 'test2.ru', -500, 1357329412, 1357329412);
INSERT INTO `taracot_billing_funds_history` VALUES (110, 1, 'refund', 'Contacts user data is invalid - test2.ru', 500, 1357329423, 1357329423);
INSERT INTO `taracot_billing_funds_history` VALUES (111, 1, 'domainregister', 'test1.ru', -500, 1357329542, 1357329542);
INSERT INTO `taracot_billing_funds_history` VALUES (112, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357329599, 1357329599);
INSERT INTO `taracot_billing_funds_history` VALUES (113, 1, 'domainregister', 'test1.ru', -500, 1357329696, 1357329696);
INSERT INTO `taracot_billing_funds_history` VALUES (114, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357329710, 1357329710);
INSERT INTO `taracot_billing_funds_history` VALUES (115, 1, 'domainregister', 'test1.ru', -500, 1357329821, 1357329821);
INSERT INTO `taracot_billing_funds_history` VALUES (116, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357329832, 1357329832);
INSERT INTO `taracot_billing_funds_history` VALUES (117, 1, 'domainregister', 'test1.ru', -500, 1357330314, 1357330314);
INSERT INTO `taracot_billing_funds_history` VALUES (118, 1, 'refund', 'No username given - test1.ru', 500, 1357330341, 1357330341);
INSERT INTO `taracot_billing_funds_history` VALUES (119, 1, 'domainregister', 'test1.ru', -500, 1357330483, 1357330483);
INSERT INTO `taracot_billing_funds_history` VALUES (120, 1, 'refund', 'No username given - test1.ru', 500, 1357330491, 1357330491);
INSERT INTO `taracot_billing_funds_history` VALUES (121, 1, 'domainregister', 'test1.ru', -500, 1357330545, 1357330545);
INSERT INTO `taracot_billing_funds_history` VALUES (122, 1, 'refund', 'No username given - test1.ru', 500, 1357330555, 1357330555);
INSERT INTO `taracot_billing_funds_history` VALUES (123, 1, 'domainregister', 'test1.ru', -500, 1357330807, 1357330807);
INSERT INTO `taracot_billing_funds_history` VALUES (124, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357330816, 1357330816);
INSERT INTO `taracot_billing_funds_history` VALUES (125, 1, 'domainregister', 'test1.ru', -500, 1357330888, 1357330888);
INSERT INTO `taracot_billing_funds_history` VALUES (126, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357330912, 1357330912);
INSERT INTO `taracot_billing_funds_history` VALUES (127, 1, 'domainregister', 'test1.ru', -500, 1357331182, 1357331182);
INSERT INTO `taracot_billing_funds_history` VALUES (128, 1, 'refund', 'No username given - test1.ru', 500, 1357331192, 1357331192);
INSERT INTO `taracot_billing_funds_history` VALUES (129, 1, 'domainregister', 'test1.ru', -500, 1357331286, 1357331286);
INSERT INTO `taracot_billing_funds_history` VALUES (130, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357331295, 1357331295);
INSERT INTO `taracot_billing_funds_history` VALUES (131, 1, 'domainregister', 'test1.ru', -500, 1357331387, 1357331387);
INSERT INTO `taracot_billing_funds_history` VALUES (132, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357331397, 1357331397);
INSERT INTO `taracot_billing_funds_history` VALUES (133, 1, 'domainregister', 'test1.ru', -500, 1357331452, 1357331452);
INSERT INTO `taracot_billing_funds_history` VALUES (134, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357331465, 1357331465);
INSERT INTO `taracot_billing_funds_history` VALUES (135, 1, 'domainregister', 'test1.ru', -500, 1357331537, 1357331537);
INSERT INTO `taracot_billing_funds_history` VALUES (136, 1, 'refund', 'No username given - test1.ru', 500, 1357331545, 1357331545);
INSERT INTO `taracot_billing_funds_history` VALUES (137, 1, 'domainregister', 'test1.ru', -500, 1357331644, 1357331644);
INSERT INTO `taracot_billing_funds_history` VALUES (138, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357331653, 1357331653);
INSERT INTO `taracot_billing_funds_history` VALUES (139, 1, 'domainregister', 'test1.ru', -500, 1357331697, 1357331697);
INSERT INTO `taracot_billing_funds_history` VALUES (140, 1, 'refund', 'Contacts user data is invalid - test1.ru', 500, 1357331706, 1357331706);
INSERT INTO `taracot_billing_funds_history` VALUES (141, 1, 'domainregister', 'ns1.ru', -500, 1357331779, 1357331779);
INSERT INTO `taracot_billing_funds_history` VALUES (142, 1, 'refund', 'Contacts user data is invalid - ns1.ru', 500, 1357331789, 1357331789);
INSERT INTO `taracot_billing_funds_history` VALUES (143, 1, 'domainregister', 't1.ru', -500, 1357331878, 1357331878);
INSERT INTO `taracot_billing_funds_history` VALUES (144, 1, 'refund', 'input_data has incorrect format or data - t1.ru', 500, 1357331892, 1357331892);
INSERT INTO `taracot_billing_funds_history` VALUES (145, 1, 'domainregister', 'test1.ru', -500, 1357331926, 1357331926);
INSERT INTO `taracot_billing_funds_history` VALUES (146, 1, 'refund', 'input_data has incorrect format or data - test1.ru', 500, 1357331935, 1357331935);
INSERT INTO `taracot_billing_funds_history` VALUES (147, 1, 'domainregister', 't1.ru', -500, 1357331989, 1357331989);
INSERT INTO `taracot_billing_funds_history` VALUES (148, 1, 'refund', 'Contacts user data is invalid - t1.ru', 500, 1357331999, 1357331999);
INSERT INTO `taracot_billing_funds_history` VALUES (149, 1, 'domainregister', 't1.ru', -500, 1357332051, 1357332051);
INSERT INTO `taracot_billing_funds_history` VALUES (150, 1, 'refund', 'Contacts user data is invalid - t1.ru', 500, 1357332077, 1357332077);
INSERT INTO `taracot_billing_funds_history` VALUES (151, 1, 'domainregister', 't1.ru', -500, 1357332472, 1357332472);
INSERT INTO `taracot_billing_funds_history` VALUES (152, 1, 'domainregister', 't2.ru', -500, 1357334214, 1357334214);
INSERT INTO `taracot_billing_funds_history` VALUES (153, 1, 'refund', 'domain_name is invalid or unsupported zone - t2.ru', 500, 1357334962, 1357334962);
INSERT INTO `taracot_billing_funds_history` VALUES (154, 1, 'domainregister', 't2.com', -500, 1357334978, 1357334978);
INSERT INTO `taracot_billing_funds_history` VALUES (155, 1, 'domainupdate', 'test.com', -500, 1357339418, 1357339418);
INSERT INTO `taracot_billing_funds_history` VALUES (156, 1, 'domainupdate', 'test.com', -500, 1357339577, 1357339577);
INSERT INTO `taracot_billing_funds_history` VALUES (157, 1, 'refund', 'Name servers list not found - test.com', 500, 1357339586, 1357339586);
INSERT INTO `taracot_billing_funds_history` VALUES (158, 1, 'domainupdate', 'test.com', -500, 1357339617, 1357339617);
INSERT INTO `taracot_billing_funds_history` VALUES (159, 1, 'domainupdate', 'test.com', -500, 1357339714, 1357339714);
INSERT INTO `taracot_billing_funds_history` VALUES (160, 1, 'refund', 'Name servers list not found - test.com', 500, 1357339724, 1357339724);
INSERT INTO `taracot_billing_funds_history` VALUES (161, 1, 'domainupdate', 'test.com', -500, 1357339948, 1357339948);
INSERT INTO `taracot_billing_funds_history` VALUES (162, 1, 'refund', 'Name servers list not found - test.com', 500, 1357339985, 1357339985);
INSERT INTO `taracot_billing_funds_history` VALUES (163, 1, 'domainupdate', 'test.com', -500, 1357340278, 1357340278);
INSERT INTO `taracot_billing_funds_history` VALUES (164, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340288, 1357340288);
INSERT INTO `taracot_billing_funds_history` VALUES (165, 1, 'domainupdate', 'test.com', -500, 1357340336, 1357340336);
INSERT INTO `taracot_billing_funds_history` VALUES (166, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340345, 1357340345);
INSERT INTO `taracot_billing_funds_history` VALUES (167, 1, 'domainupdate', 'test.com', -500, 1357340404, 1357340404);
INSERT INTO `taracot_billing_funds_history` VALUES (168, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340440, 1357340440);
INSERT INTO `taracot_billing_funds_history` VALUES (169, 1, 'domainupdate', 'test.com', -500, 1357340531, 1357340531);
INSERT INTO `taracot_billing_funds_history` VALUES (170, 1, 'domainupdate', 'test.com', -500, 1357340595, 1357340595);
INSERT INTO `taracot_billing_funds_history` VALUES (171, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340610, 1357340610);
INSERT INTO `taracot_billing_funds_history` VALUES (172, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340638, 1357340638);
INSERT INTO `taracot_billing_funds_history` VALUES (173, 1, 'domainupdate', 'test.com', -500, 1357340654, 1357340654);
INSERT INTO `taracot_billing_funds_history` VALUES (174, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340667, 1357340667);
INSERT INTO `taracot_billing_funds_history` VALUES (175, 1, 'domainupdate', 'test.com', -500, 1357340680, 1357340680);
INSERT INTO `taracot_billing_funds_history` VALUES (176, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340805, 1357340805);
INSERT INTO `taracot_billing_funds_history` VALUES (177, 1, 'domainupdate', 'test.com', -500, 1357340871, 1357340871);
INSERT INTO `taracot_billing_funds_history` VALUES (178, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340884, 1357340884);
INSERT INTO `taracot_billing_funds_history` VALUES (179, 1, 'domainupdate', 'test.com', -500, 1357340900, 1357340900);
INSERT INTO `taracot_billing_funds_history` VALUES (180, 1, 'refund', 'Name servers list not found - test.com', 500, 1357340920, 1357340920);
INSERT INTO `taracot_billing_funds_history` VALUES (181, 1, 'domainupdate', 'test.com', -500, 1357341010, 1357341010);
INSERT INTO `taracot_billing_funds_history` VALUES (182, 1, 'domainupdate', 'test.com', -500, 1357341080, 1357341080);
INSERT INTO `taracot_billing_funds_history` VALUES (183, 1, 'domainupdate', 'test.com', -500, 1357376597, 1357376597);
INSERT INTO `taracot_billing_funds_history` VALUES (184, 1, 'refund', 'Name servers list not found - test.com', 500, 1357376633, 1357376633);
INSERT INTO `taracot_billing_funds_history` VALUES (185, 1, 'domainupdate', 'test.com', -500, 1357376810, 1357376810);
INSERT INTO `taracot_billing_funds_history` VALUES (186, 1, 'refund', 'Name servers list not found - test.com', 500, 1357376821, 1357376821);
INSERT INTO `taracot_billing_funds_history` VALUES (187, 1, 'domainupdate', 'test.com', -500, 1357411740, 1357411740);
INSERT INTO `taracot_billing_funds_history` VALUES (188, 1, 'refund', 'Name servers list not found - test.com', 500, 1357411752, 1357411752);
INSERT INTO `taracot_billing_funds_history` VALUES (189, 1, 'domainupdate', 'test.com', -500, 1357411798, 1357411798);
INSERT INTO `taracot_billing_funds_history` VALUES (190, 1, 'domainupdate', 're-hash.ru', -400, 1357411976, 1357411976);
INSERT INTO `taracot_billing_funds_history` VALUES (191, 1, 'hostingupdate', 'oursik', -199, 1357414818, 1357414818);
INSERT INTO `taracot_billing_funds_history` VALUES (192, 1, 'hostingupdate', 'oursik', -199, 1357415156, 1357415156);
INSERT INTO `taracot_billing_funds_history` VALUES (193, 1, 'refund', 'Oh shit, it failed - oursik', 199, 1357415163, 1357415163);
INSERT INTO `taracot_billing_funds_history` VALUES (194, 1, 'hostingupdate', 'oursik', -199, 1357415283, 1357415283);
INSERT INTO `taracot_billing_funds_history` VALUES (195, 1, 'refund', 'Oh shit, it failed - oursik', 199, 1357415289, 1357415289);
INSERT INTO `taracot_billing_funds_history` VALUES (196, 1, 'hostingupdate', 'oursik', -199, 1357415744, 1357415744);
INSERT INTO `taracot_billing_funds_history` VALUES (197, 1, 'hostingupdate', 'mdvd', -199, 1357417231, 1357417231);
INSERT INTO `taracot_billing_funds_history` VALUES (198, 1, 'refund', 'Error while updating the hosting account - mdvd', 199, 1357421176, 1357421176);
INSERT INTO `taracot_billing_funds_history` VALUES (199, 1, 'hostingupdate', 'mdvd', -199, 1357421286, 1357421286);
INSERT INTO `taracot_billing_funds_history` VALUES (200, 1, 'refund', 'Error while updating the hosting account - mdvd', 199, 1357421305, 1357421305);
INSERT INTO `taracot_billing_funds_history` VALUES (201, 1, 'hostingupdate', 'mdvd', -199, 1357421386, 1357421386);
INSERT INTO `taracot_billing_funds_history` VALUES (202, 1, 'refund', 'Error while updating the hosting account - mdvd', 199, 1357421397, 1357421397);
INSERT INTO `taracot_billing_funds_history` VALUES (203, 1, 'hostingregister', 't333', -199, 1357425897, 1357425897);
INSERT INTO `taracot_billing_funds_history` VALUES (204, 1, 'hostingregister', 'medved', -199, 1357425947, 1357425947);
INSERT INTO `taracot_billing_funds_history` VALUES (205, 1, 'refund', 'Error while creating new user account - t333', 199, 1357425968, 1357425968);
INSERT INTO `taracot_billing_funds_history` VALUES (206, 1, 'refund', 'Error while creating new user account - medved', 199, 1357426022, 1357426022);
INSERT INTO `taracot_billing_funds_history` VALUES (207, 1, 'hostingregister', 'medved', -199, 1357427088, 1357427088);
INSERT INTO `taracot_billing_funds_history` VALUES (208, 1, 'hostingregister', 'medved11', -199, 1357427122, 1357427122);
INSERT INTO `taracot_billing_funds_history` VALUES (209, 1, 'refund', 'Error while creating new user account - medved11', 199, 1357427156, 1357427156);
INSERT INTO `taracot_billing_funds_history` VALUES (210, 1, 'hostingregister', 'medved2', -199, 1357427702, 1357427702);
INSERT INTO `taracot_billing_funds_history` VALUES (211, 1, 'refund', 'Error while creating new user account - medved2', 199, 1357427717, 1357427717);
INSERT INTO `taracot_billing_funds_history` VALUES (212, 1, 'hostingregister', 'medved21', -199, 1357427814, 1357427814);
INSERT INTO `taracot_billing_funds_history` VALUES (213, 1, 'refund', 'Error while creating new user account - medved21', 199, 1357427829, 1357427829);
INSERT INTO `taracot_billing_funds_history` VALUES (214, 1, 'domainregister', 'microsoft.com', -500, 1357428220, 1357428220);
INSERT INTO `taracot_billing_funds_history` VALUES (215, 1, 'domainregister', 'ms2.com', -500, 1357428297, 1357428297);
INSERT INTO `taracot_billing_funds_history` VALUES (216, 1, 'refund', 'Username/password Incorrect - ms2.com', 500, 1357428308, 1357428308);
INSERT INTO `taracot_billing_funds_history` VALUES (217, 1, 'domainupdate', 'test.com', -500, 1357428541, 1357428541);
INSERT INTO `taracot_billing_funds_history` VALUES (218, 1, 'refund', 'Username/password Incorrect - test.com', 500, 1357428549, 1357428549);
INSERT INTO `taracot_billing_funds_history` VALUES (219, 1, 'hostingupdate', 'mdvd', -199, 1357428765, 1357428765);
INSERT INTO `taracot_billing_funds_history` VALUES (220, 1, 'refund', 'Error while updating the hosting account - mdvd', 199, 1357428774, 1357428774);
INSERT INTO `taracot_billing_funds_history` VALUES (221, 1, 'hostingupdate', 'medved', -199, 1357429105, 1357429105);
INSERT INTO `taracot_billing_funds_history` VALUES (222, 1, 'refund', 'Error while updating the hosting account - medved', 199, 1357429113, 1357429113);
INSERT INTO `taracot_billing_funds_history` VALUES (223, 1, 'hostingupdate', 'medved', -199, 1357429275, 1357429275);
INSERT INTO `taracot_billing_funds_history` VALUES (224, 1, 'refund', 'Error while updating the hosting account - medved', 199, 1357429283, 1357429283);
INSERT INTO `taracot_billing_funds_history` VALUES (225, 1, 'hostingupdate', 'medved', -199, 1357429339, 1357429339);
INSERT INTO `taracot_billing_funds_history` VALUES (226, 1, 'refund', 'Error while updating the hosting account - medved', 199, 1357429348, 1357429348);
INSERT INTO `taracot_billing_funds_history` VALUES (227, 1, 'hostingregister', 'test', -199, 1357504420, 1357504420);
INSERT INTO `taracot_billing_funds_history` VALUES (228, 1, 'hostingregister', 'test2', -199, 1357504459, 1357504459);
INSERT INTO `taracot_billing_funds_history` VALUES (229, 1, 'hostingregister', 'test3', -199, 1357504511, 1357504511);
INSERT INTO `taracot_billing_funds_history` VALUES (230, 1, 'hostingregister', 'test', -199, 1357504675, 1357504675);
INSERT INTO `taracot_billing_funds_history` VALUES (231, 1, 'hostingupdate', 'test', -199, 1357504767, 1357504767);
INSERT INTO `taracot_billing_funds_history` VALUES (232, 1, 'domainregister', 'test.com', -500, 1357505152, 1357505152);
INSERT INTO `taracot_billing_funds_history` VALUES (233, 1, 'domainupdate', 'test.com', -500, 1357505217, 1357505217);
INSERT INTO `taracot_billing_funds_history` VALUES (234, 1, 'serviceupdate', 'backup', -666, 1357505285, 1357505285);
INSERT INTO `taracot_billing_funds_history` VALUES (235, 1, 'domainupdate', 'test.com', -500, 1357505316, 1357505316);
INSERT INTO `taracot_billing_funds_history` VALUES (236, 1, 'domainupdate', 'test.com', -500, 1357505341, 1357505341);
INSERT INTO `taracot_billing_funds_history` VALUES (237, 1, 'hostingupdate', 'test', -199, 1357506329, 1357506329);
INSERT INTO `taracot_billing_funds_history` VALUES (238, 1, 'hostingupdate', 'test', -199, 1357506373, 1357506373);
INSERT INTO `taracot_billing_funds_history` VALUES (239, 1, 'domainregister', 'test.com', -500, 1357506409, 1357506409);
INSERT INTO `taracot_billing_funds_history` VALUES (240, 1, 'hostingregister', 'test', -199, 1357507889, 1357507889);
INSERT INTO `taracot_billing_funds_history` VALUES (241, 1, 'hostingregister', 'test', -199, 1357507944, 1357507944);
INSERT INTO `taracot_billing_funds_history` VALUES (242, 1, 'hostingregister', 'test', -199, 1357508471, 1357508471);
INSERT INTO `taracot_billing_funds_history` VALUES (243, 1, 'domainregister', 'test.com', -500, 1357508622, 1357508622);
INSERT INTO `taracot_billing_funds_history` VALUES (244, 1, 'domainregister', 'test2.com', -500, 1357595651, 1357595651);
INSERT INTO `taracot_billing_funds_history` VALUES (245, 1, 'hostingregister', 'test', -199, 1357596637, 1357596637);
INSERT INTO `taracot_billing_funds_history` VALUES (246, 1, 'addfunds', '', 100, 1357640100, 1357597264);
INSERT INTO `taracot_billing_funds_history` VALUES (247, 1, 'domainupdate', 'test.com', -500, 1357600827, 1357600827);
INSERT INTO `taracot_billing_funds_history` VALUES (248, 1, 'domainupdate', 'test.com', -500, 1357638846, 1357638846);
INSERT INTO `taracot_billing_funds_history` VALUES (249, 1, 'hostingupdate', 'test', -199, 1357638857, 1357638857);
INSERT INTO `taracot_billing_funds_history` VALUES (250, 1, 'hostingupdate', 'test', -199, 1357638896, 1357638896);
INSERT INTO `taracot_billing_funds_history` VALUES (251, 1, 'hostingupdate', 'test', -199, 1357638924, 1357638924);
INSERT INTO `taracot_billing_funds_history` VALUES (252, 1, 'serviceupdate', 'backup', -666, 1357640724, 1357640724);
INSERT INTO `taracot_billing_funds_history` VALUES (253, 1, 'domainregister', 'test2.com', -500, 1357641329, 1357641329);
INSERT INTO `taracot_billing_funds_history` VALUES (254, 1, 'domainregister', 'test3.com', -500, 1357641374, 1357641374);
INSERT INTO `taracot_billing_funds_history` VALUES (255, 1, 'domainregister', 'test.com', -500, 1357643267, 1357643267);
INSERT INTO `taracot_billing_funds_history` VALUES (256, 1, 'domainregister', 'test2.com', -500, 1357664012, 1357664012);

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
) ENGINE=MyISAM AUTO_INCREMENT=113 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=40 AUTO_INCREMENT=113 ;

-- 
-- Dumping data for table `taracot_billing_hosting`
-- 

INSERT INTO `taracot_billing_hosting` VALUES (112, 1, 'test', 'econom', 6, NULL, NULL, NULL, 0, 1357675422);

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
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_billing_profiles`
-- 

INSERT INTO `taracot_billing_profiles` VALUES (1, 1, '', 'Petrov', '', 'Vasily', '', 'A', 'xtreme@rh1.ru', '+7 921 7998111', '+7 812 9883535', 'AF', 'St. Petersburg', 'LEN', 'Michmanskaya Str. 2-1-212', '199226', '', '16.02.1985', '', '', '', '', '', 1, 1357600323);
INSERT INTO `taracot_billing_profiles` VALUES (2, 9, 'Петров', 'Smith', 'Иван', 'John', 'Иванович', 'I', 'john.smith@domain.com', '+7 495 1234567', '+7 495 1234589', 'RE', 'New York', 'New York', 'Tverskaya St., 2-1-234', NULL, '34 02 651241 выдан 48 о/м г. Москвы 26.12.1990', '30.11.1985', '101000, Москва, ул. Воробьянинова, 15, кв. 22, В. Лоханкину', 'ROGA I KOPYTA, LTD.', 'Общество с ограниченной ответственностью "Рога и Копыта"', '7701107259', '632946014', 0, 1354883028);

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
) ENGINE=MyISAM AUTO_INCREMENT=116 DEFAULT CHARSET=utf8 AUTO_INCREMENT=116 ;

-- 
-- Dumping data for table `taracot_billing_queue`
-- 

INSERT INTO `taracot_billing_queue` VALUES (115, 1, 'domainregister', 'test2.com', 'en', 1357664012, 500);
INSERT INTO `taracot_billing_queue` VALUES (114, 1, 'domainregister', 'test.com', 'en', 1357643267, 500);

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
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 AUTO_INCREMENT=8 ;

-- 
-- Dumping data for table `taracot_billing_services`
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
  `chash` varchar(24) default NULL,
  `left_key` int(10) NOT NULL,
  `right_key` int(10) NOT NULL,
  `level` int(10) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `left_key` (`left_key`,`right_key`,`level`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

-- 
-- Dumping data for table `taracot_blog_comments`
-- 

INSERT INTO `taracot_blog_comments` VALUES (1, 51, 0, 'admin', 'First comment goes here! However, what I do (this is cheating) is I combined the nested set with adjacency lists -- I embed a &quot;parent_id&quot; in the table, so I can easily ask for the children of a node.', 1375372669, NULL, 1, 8, 1);
INSERT INTO `taracot_blog_comments` VALUES (2, 51, 0, 'admin', 'User &quot;bobince&quot; almost had it. I figured it out and got it to work for me because I have a little more MySQL experience than most. However, I can see why bobince''s answer might scare people off. His query is incomplete. You need to select the parent_left and parent_right into mysql variables first. ', 1375372696, NULL, 4, 7, 2);
INSERT INTO `taracot_blog_comments` VALUES (3, 51, 0, 'admin', 'Another comment within root node', 1375372706, NULL, 9, 12, 1);

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
  `lastchanged` int(11) default NULL,
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `ptags` (`ptags`)
) ENGINE=MyISAM AUTO_INCREMENT=52 DEFAULT CHARSET=utf8 AUTO_INCREMENT=52 ;

-- 
-- Dumping data for table `taracot_blog_posts`
-- 

INSERT INTO `taracot_blog_posts` VALUES (51, 'en', 'admin', 'misc', 1, 'Тестовый пост!', 'теги, bbcode', 1375085854, '[b]Bold\n[/b][i]Ital[/i]ic\n[u]Underline\n[/u][s]Strike\n[/s][sup]Sup\n[/sup][sub]Sub[/sub]\n[img]http://yandex.st/lego/_/X31pO5JJJKEifJ7sfvuf3mGeD_8.png[/img]﻿\n[img width=100,height=100]http://yandex.st/lego/_/X31pO5JJJKEifJ7sfvuf3mGeD_8.png[/img]﻿\n[url=http://google.com]Google[/url]\nList type 1:\n[list][*]LI1[/*][*]LI2[/*][*]LI3[/*][/list][cut]Another list:\n[list=1][*]LI1[/*][*]LI2[/*][*]LI3[/*][/list]\n[color=rgb(168,168,168)]RGB Color test[/color]\n[color=#ff0000]Red text\n[color=rgb(68, 68, 68)]Auto text\n[color=#000000]Black text\n[font=Verdana]Verdana text[/font][/color][/color][/color]\nAlign left\n[center]Align center[/center]\n[right]Align right\nAnother one[/right][code]package taracot::AUBBC;\nuse strict;\nuse warnings;\n\nour $VERSION     = ''4.06'';\nour $BAD_MESSAGE = ''Unathorized'';\nour $DEBUG_AUBBC = 0;\nour $MEMOIZE     = 1;[/code]\n[offtop]And offtop goes here[/offtop]\n[table][tr][td]cell1﻿[/td][td]cell2﻿[/td][/tr][tr][td]﻿cell3[/td][td]﻿cell4[/td][/tr][/table]\n[size=100]Нормальный текст[/size]\n[size=85]Маленький текст[/size]\n[size=200]Очень большой текст[/size]\n[size=100]Нормальный текст[/size]\n[size=50]Очень маленький текст[/size]\n\n[quote]Цитата[/quote]\n[quote=Цитата великого медведа]Цитата[/quote]', '<b>Bold<br />\n</b><i>Ital</i>ic<br />\n<span style="text-decoration: underline;">Underline<br />\n</span><span style="text-decoration: line-through;">Strike<br />\n</span><sup>Sup<br />\n</sup><sub>Sub</sub><br />\n<img src="http://yandex.st/lego/_/X31pO5JJJKEifJ7sfvuf3mGeD_8.png" width="90" height="60" alt="" border="0" /> ﻿<br />\n<img src="http://yandex.st/lego/_/X31pO5JJJKEifJ7sfvuf3mGeD_8.png" width="100" height="100" alt="" border="0" /> ﻿<br />\n<a href="http://google.com" target="_blank">Google</a><br />\nList type 1:<br />\n<ul>\n<li>LI1</li>\n<li>LI2</li>\n<li>LI3</li>\n</ul>', 1, '<b>Bold<br />\n</b><i>Ital</i>ic<br />\n<span style="text-decoration: underline;">Underline<br />\n</span><span style="text-decoration: line-through;">Strike<br />\n</span><sup>Sup<br />\n</sup><sub>Sub</sub><br />\n<img src="http://yandex.st/lego/_/X31pO5JJJKEifJ7sfvuf3mGeD_8.png" width="90" height="60" alt="" border="0" /> ﻿<br />\n<img src="http://yandex.st/lego/_/X31pO5JJJKEifJ7sfvuf3mGeD_8.png" width="100" height="100" alt="" border="0" /> ﻿<br />\n<a href="http://google.com" target="_blank">Google</a><br />\nList type 1:<br />\n<ul>\n<li>LI1</li>\n<li>LI2</li>\n<li>LI3</li>\n</ul> Another list:<br />\n<ol>\n<li>LI1</li>\n<li>LI2</li>\n<li>LI3</li>\n</ol>\n<span style="color:rgb(168,168,168);">RGB Color test</span><br />\n<span style="color:#ff0000;">Red text<br />\n<span style="color:rgb(68,68,68);">Auto text<br />\n<span style="color:#000000;">Black text<br />\n<span style="font-family:Verdana;">Verdana text</span></span></span></span><br />\nAlign left<br />\n<div style="text-align: center;">Align center</div><br />\n<div style="text-align: right;">Align right<br />\nAnother one</div><div><code>\n<span>package</span> taracot&#58;&#58;AUBBC&#59;<br />\n<span>use</span> <span>strict</span>&#59;<br />\n<span>use</span> warnings&#59;<br />\n<br />\nour <span>$VERSION</span> &nbsp; &nbsp; = <span>&#39;<span>4</span>.<span>06</span>&#39;</span>&#59;<br />\nour <span>$BAD_MESSAGE</span> = <span>&#39;Unathorized&#39;</span>&#59;<br />\nour <span>$DEBUG_AUBBC</span> = <span>0</span>&#59;<br />\nour <span>$MEMOIZE</span> &nbsp; &nbsp; = <span>1</span>&#59;<br />\n</code></div><br />\n<span style="color:#666;">And offtop goes here</span><br />\n<table class="table table-striped table-bordered"><tr><td>cell1﻿</td><td>cell2﻿</td></tr><tr><td>﻿cell3</td><td>﻿cell4</td></tr></table><br />\n<span style="font-size: 100%;">Нормальный текст</span><br />\n<span style="font-size: 85%;">Маленький текст</span><br />\n<span style="font-size: 200%;">Очень большой текст</span><br />\n<span style="font-size: 100%;">Нормальный текст</span><br />\n<span style="font-size: 50%;">Очень маленький текст</span><br />\n<br />\n<blockquote>Цитата</blockquote><br />\n<blockquote><small><strong>Цитата великого медведа:</strong></small><br />\nЦитата</blockquote>', 344, 1375276341);

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
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=18466 AUTO_INCREMENT=3 ;

-- 
-- Dumping data for table `taracot_pages`
-- 

INSERT INTO `taracot_pages` VALUES (1, 'Home', 'Page keywordz', 'Page description', '<p>\n	Hello!</p>\n', 1, '/', 'en', 'taracot', 1358176801);
INSERT INTO `taracot_pages` VALUES (2, 'This is my License', 'Page keywordz', 'Page description', '<div dir="ltr">\n	<h1>\n		License</h1>\n	<h3>\n		GNU GENERAL PUBLIC LICENSE</h3>\n	<p>\n		Version 3, 29 June 2007</p>\n	<p>\n		Copyright &copy; 2007 Free Software Foundation, Inc. &lt;<a href="http://fsf.org/">http://fsf.org/</a>&gt;</p>\n	<p>\n		Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.</p>\n	<h3>\n		Preamble</h3>\n	<p>\n		The GNU General Public License is a free, copyleft license for software and other kinds of works.</p>\n	<p>\n		The licenses for most software and other practical works are designed to take away your freedom to share and change the works. By contrast, the GNU General Public License is intended to guarantee your freedom to share and change all versions of a program--to make sure it remains free software for all its users. We, the Free Software Foundation, use the GNU General Public License for most of our software; it applies also to any other work released this way by its authors. You can apply it to your programs, too.</p>\n	<p>\n		When we speak of free software, we are referring to freedom, not price. Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for them if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs, and that you know you can do these things.</p>\n	<p>\n		To protect your rights, we need to prevent others from denying you these rights or asking you to surrender the rights. Therefore, you have certain responsibilities if you distribute copies of the software, or if you modify it: responsibilities to respect the freedom of others.</p>\n	<p>\n		For example, if you distribute copies of such a program, whether gratis or for a fee, you must pass on to the recipients the same freedoms that you received. You must make sure that they, too, receive or can get the source code. And you must show them these terms so they know their rights.</p>\n	<p>\n		Developers that use the GNU GPL protect your rights with two steps: (1) assert copyright on the software, and (2) offer you this License giving you legal permission to copy, distribute and/or modify it.</p>\n	<p>\n		For the developers&#39; and authors&#39; protection, the GPL clearly explains that there is no warranty for this free software. For both users&#39; and authors&#39; sake, the GPL requires that modified versions be marked as changed, so that their problems will not be attributed erroneously to authors of previous versions.</p>\n	<p>\n		Some devices are designed to deny users access to install or run modified versions of the software inside them, although the manufacturer can do so. This is fundamentally incompatible with the aim of protecting users&#39; freedom to change the software. The systematic pattern of such abuse occurs in the area of products for individuals to use, which is precisely where it is most unacceptable. Therefore, we have designed this version of the GPL to prohibit the practice for those products. If such problems arise substantially in other domains, we stand ready to extend this provision to those domains in future versions of the GPL, as needed to protect the freedom of users.</p>\n	<p>\n		Finally, every program is threatened constantly by software patents. States should not allow patents to restrict development and use of software on general-purpose computers, but in those that do, we wish to avoid the special danger that patents applied to a free program could make it effectively proprietary. To prevent this, the GPL assures that patents cannot be used to render the program non-free.</p>\n	<p>\n		The precise terms and conditions for copying, distribution and modification follow.</p>\n	<h3>\n		TERMS AND CONDITIONS</h3>\n	<h4>\n		0. Definitions.</h4>\n	<p>\n		&ldquo;This License&rdquo; refers to version 3 of the GNU General Public License.</p>\n	<p>\n		&ldquo;Copyright&rdquo; also means copyright-like laws that apply to other kinds of works, such as semiconductor masks.</p>\n	<p>\n		&ldquo;The Program&rdquo; refers to any copyrightable work licensed under this License. Each licensee is addressed as &ldquo;you&rdquo;. &ldquo;Licensees&rdquo; and &ldquo;recipients&rdquo; may be individuals or organizations.</p>\n	<p>\n		To &ldquo;modify&rdquo; a work means to copy from or adapt all or part of the work in a fashion requiring copyright permission, other than the making of an exact copy. The resulting work is called a &ldquo;modified version&rdquo; of the earlier work or a work &ldquo;based on&rdquo; the earlier work.</p>\n	<p>\n		A &ldquo;covered work&rdquo; means either the unmodified Program or a work based on the Program.</p>\n	<p>\n		To &ldquo;propagate&rdquo; a work means to do anything with it that, without permission, would make you directly or secondarily liable for infringement under applicable copyright law, except executing it on a computer or modifying a private copy. Propagation includes copying, distribution (with or without modification), making available to the public, and in some countries other activities as well.</p>\n	<p>\n		To &ldquo;convey&rdquo; a work means any kind of propagation that enables other parties to make or receive copies. Mere interaction with a user through a computer network, with no transfer of a copy, is not conveying.</p>\n	<p>\n		An interactive user interface displays &ldquo;Appropriate Legal Notices&rdquo; to the extent that it includes a convenient and prominently visible feature that (1) displays an appropriate copyright notice, and (2) tells the user that there is no warranty for the work (except to the extent that warranties are provided), that licensees may convey the work under this License, and how to view a copy of this License. If the interface presents a list of user commands or options, such as a menu, a prominent item in the list meets this criterion.</p>\n	<h4>\n		1. Source Code.</h4>\n	<p>\n		The &ldquo;source code&rdquo; for a work means the preferred form of the work for making modifications to it. &ldquo;Object code&rdquo; means any non-source form of a work.</p>\n	<p>\n		A &ldquo;Standard Interface&rdquo; means an interface that either is an official standard defined by a recognized standards body, or, in the case of interfaces specified for a particular programming language, one that is widely used among developers working in that language.</p>\n	<p>\n		The &ldquo;System Libraries&rdquo; of an executable work include anything, other than the work as a whole, that (a) is included in the normal form of packaging a Major Component, but which is not part of that Major Component, and (b) serves only to enable use of the work with that Major Component, or to implement a Standard Interface for which an implementation is available to the public in source code form. A &ldquo;Major Component&rdquo;, in this context, means a major essential component (kernel, window system, and so on) of the specific operating system (if any) on which the executable work runs, or a compiler used to produce the work, or an object code interpreter used to run it.</p>\n	<p>\n		The &ldquo;Corresponding Source&rdquo; for a work in object code form means all the source code needed to generate, install, and (for an executable work) run the object code and to modify the work, including scripts to control those activities. However, it does not include the work&#39;s System Libraries, or general-purpose tools or generally available free programs which are used unmodified in performing those activities but which are not part of the work. For example, Corresponding Source includes interface definition files associated with source files for the work, and the source code for shared libraries and dynamically linked subprograms that the work is specifically designed to require, such as by intimate data communication or control flow between those subprograms and other parts of the work.</p>\n	<p>\n		The Corresponding Source need not include anything that users can regenerate automatically from other parts of the Corresponding Source.</p>\n	<p>\n		The Corresponding Source for a work in source code form is that same work.</p>\n	<h4>\n		2. Basic Permissions.</h4>\n	<p>\n		All rights granted under this License are granted for the term of copyright on the Program, and are irrevocable provided the stated conditions are met. This License explicitly affirms your unlimited permission to run the unmodified Program. The output from running a covered work is covered by this License only if the output, given its content, constitutes a covered work. This License acknowledges your rights of fair use or other equivalent, as provided by copyright law.</p>\n	<p>\n		You may make, run and propagate covered works that you do not convey, without conditions so long as your license otherwise remains in force. You may convey covered works to others for the sole purpose of having them make modifications exclusively for you, or provide you with facilities for running those works, provided that you comply with the terms of this License in conveying all material for which you do not control copyright. Those thus making or running the covered works for you must do so exclusively on your behalf, under your direction and control, on terms that prohibit them from making any copies of your copyrighted material outside their relationship with you.</p>\n	<p>\n		Conveying under any other circumstances is permitted solely under the conditions stated below. Sublicensing is not allowed; section 10 makes it unnecessary.</p>\n	<h4>\n		3. Protecting Users&#39; Legal Rights From Anti-Circumvention Law.</h4>\n	<p>\n		No covered work shall be deemed part of an effective technological measure under any applicable law fulfilling obligations under article 11 of the WIPO copyright treaty adopted on 20 December 1996, or similar laws prohibiting or restricting circumvention of such measures.</p>\n	<p>\n		When you convey a covered work, you waive any legal power to forbid circumvention of technological measures to the extent such circumvention is effected by exercising rights under this License with respect to the covered work, and you disclaim any intention to limit operation or modification of the work as a means of enforcing, against the work&#39;s users, your or third parties&#39; legal rights to forbid circumvention of technological measures.</p>\n	<h4>\n		4. Conveying Verbatim Copies.</h4>\n	<p>\n		You may convey verbatim copies of the Program&#39;s source code as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice; keep intact all notices stating that this License and any non-permissive terms added in accord with section 7 apply to the code; keep intact all notices of the absence of any warranty; and give all recipients a copy of this License along with the Program.</p>\n	<p>\n		You may charge any price or no price for each copy that you convey, and you may offer support or warranty protection for a fee.</p>\n	<h4>\n		5. Conveying Modified Source Versions.</h4>\n	<p>\n		You may convey a work based on the Program, or the modifications to produce it from the Program, in the form of source code under the terms of section 4, provided that you also meet all of these conditions:</p>\n	<ul>\n		<li>\n			a) The work must carry prominent notices stating that you modified it, and giving a relevant date.</li>\n		<li>\n			b) The work must carry prominent notices stating that it is released under this License and any conditions added under section 7. This requirement modifies the requirement in section 4 to &ldquo;keep intact all notices&rdquo;.</li>\n		<li>\n			c) You must license the entire work, as a whole, under this License to anyone who comes into possession of a copy. This License will therefore apply, along with any applicable section 7 additional terms, to the whole of the work, and all its parts, regardless of how they are packaged. This License gives no permission to license the work in any other way, but it does not invalidate such permission if you have separately received it.</li>\n		<li>\n			d) If the work has interactive user interfaces, each must display Appropriate Legal Notices; however, if the Program has interactive interfaces that do not display Appropriate Legal Notices, your work need not make them do so.</li>\n	</ul>\n	<p>\n		A compilation of a covered work with other separate and independent works, which are not by their nature extensions of the covered work, and which are not combined with it such as to form a larger program, in or on a volume of a storage or distribution medium, is called an &ldquo;aggregate&rdquo; if the compilation and its resulting copyright are not used to limit the access or legal rights of the compilation&#39;s users beyond what the individual works permit. Inclusion of a covered work in an aggregate does not cause this License to apply to the other parts of the aggregate.</p>\n	<h4>\n		6. Conveying Non-Source Forms.</h4>\n	<p>\n		You may convey a covered work in object code form under the terms of sections 4 and 5, provided that you also convey the machine-readable Corresponding Source under the terms of this License, in one of these ways:</p>\n	<ul>\n		<li>\n			a) Convey the object code in, or embodied in, a physical product (including a physical distribution medium), accompanied by the Corresponding Source fixed on a durable physical medium customarily used for software interchange.</li>\n		<li>\n			b) Convey the object code in, or embodied in, a physical product (including a physical distribution medium), accompanied by a written offer, valid for at least three years and valid for as long as you offer spare parts or customer support for that product model, to give anyone who possesses the object code either (1) a copy of the Corresponding Source for all the software in the product that is covered by this License, on a durable physical medium customarily used for software interchange, for a price no more than your reasonable cost of physically performing this conveying of source, or (2) access to copy the Corresponding Source from a network server at no charge.</li>\n		<li>\n			c) Convey individual copies of the object code with a copy of the written offer to provide the Corresponding Source. This alternative is allowed only occasionally and noncommercially, and only if you received the object code with such an offer, in accord with subsection 6b.</li>\n		<li>\n			d) Convey the object code by offering access from a designated place (gratis or for a charge), and offer equivalent access to the Corresponding Source in the same way through the same place at no further charge. You need not require recipients to copy the Corresponding Source along with the object code. If the place to copy the object code is a network server, the Corresponding Source may be on a different server (operated by you or a third party) that supports equivalent copying facilities, provided you maintain clear directions next to the object code saying where to find the Corresponding Source. Regardless of what server hosts the Corresponding Source, you remain obligated to ensure that it is available for as long as needed to satisfy these requirements.</li>\n		<li>\n			e) Convey the object code using peer-to-peer transmission, provided you inform other peers where the object code and Corresponding Source of the work are being offered to the general public at no charge under subsection 6d.</li>\n	</ul>\n	<p>\n		A separable portion of the object code, whose source code is excluded from the Corresponding Source as a System Library, need not be included in conveying the object code work.</p>\n	<p>\n		A &ldquo;User Product&rdquo; is either (1) a &ldquo;consumer product&rdquo;, which means any tangible personal property which is normally used for personal, family, or household purposes, or (2) anything designed or sold for incorporation into a dwelling. In determining whether a product is a consumer product, doubtful cases shall be resolved in favor of coverage. For a particular product received by a particular user, &ldquo;normally used&rdquo; refers to a typical or common use of that class of product, regardless of the status of the particular user or of the way in which the particular user actually uses, or expects or is expected to use, the product. A product is a consumer product regardless of whether the product has substantial commercial, industrial or non-consumer uses, unless such uses represent the only significant mode of use of the product.</p>\n	<p>\n		&ldquo;Installation Information&rdquo; for a User Product means any methods, procedures, authorization keys, or other information required to install and execute modified versions of a covered work in that User Product from a modified version of its Corresponding Source. The information must suffice to ensure that the continued functioning of the modified object code is in no case prevented or interfered with solely because modification has been made.</p>\n	<p>\n		If you convey an object code work under this section in, or with, or specifically for use in, a User Product, and the conveying occurs as part of a transaction in which the right of possession and use of the User Product is transferred to the recipient in perpetuity or for a fixed term (regardless of how the transaction is characterized), the Corresponding Source conveyed under this section must be accompanied by the Installation Information. But this requirement does not apply if neither you nor any third party retains the ability to install modified object code on the User Product (for example, the work has been installed in ROM).</p>\n	<p>\n		The requirement to provide Installation Information does not include a requirement to continue to provide support service, warranty, or updates for a work that has been modified or installed by the recipient, or for the User Product in which it has been modified or installed. Access to a network may be denied when the modification itself materially and adversely affects the operation of the network or violates the rules and protocols for communication across the network.</p>\n	<p>\n		Corresponding Source conveyed, and Installation Information provided, in accord with this section must be in a format that is publicly documented (and with an implementation available to the public in source code form), and must require no special password or key for unpacking, reading or copying.</p>\n	<h4>\n		7. Additional Terms.</h4>\n	<p>\n		&ldquo;Additional permissions&rdquo; are terms that supplement the terms of this License by making exceptions from one or more of its conditions. Additional permissions that are applicable to the entire Program shall be treated as though they were included in this License, to the extent that they are valid under applicable law. If additional permissions apply only to part of the Program, that part may be used separately under those permissions, but the entire Program remains governed by this License without regard to the additional permissions.</p>\n	<p>\n		When you convey a copy of a covered work, you may at your option remove any additional permissions from that copy, or from any part of it. (Additional permissions may be written to require their own removal in certain cases when you modify the work.) You may place additional permissions on material, added by you to a covered work, for which you have or can give appropriate copyright permission.</p>\n	<p>\n		Notwithstanding any other provision of this License, for material you add to a covered work, you may (if authorized by the copyright holders of that material) supplement the terms of this License with terms:</p>\n	<ul>\n		<li>\n			a) Disclaiming warranty or limiting liability differently from the terms of sections 15 and 16 of this License; or</li>\n		<li>\n			b) Requiring preservation of specified reasonable legal notices or author attributions in that material or in the Appropriate Legal Notices displayed by works containing it; or</li>\n		<li>\n			c) Prohibiting misrepresentation of the origin of that material, or requiring that modified versions of such material be marked in reasonable ways as different from the original version; or</li>\n		<li>\n			d) Limiting the use for publicity purposes of names of licensors or authors of the material; or</li>\n		<li>\n			e) Declining to grant rights under trademark law for use of some trade names, trademarks, or service marks; or</li>\n		<li>\n			f) Requiring indemnification of licensors and authors of that material by anyone who conveys the material (or modified versions of it) with contractual assumptions of liability to the recipient, for any liability that these contractual assumptions directly impose on those licensors and authors.</li>\n	</ul>\n	<p>\n		All other non-permissive additional terms are considered &ldquo;further restrictions&rdquo; within the meaning of section 10. If the Program as you received it, or any part of it, contains a notice stating that it is governed by this License along with a term that is a further restriction, you may remove that term. If a license document contains a further restriction but permits relicensing or conveying under this License, you may add to a covered work material governed by the terms of that license document, provided that the further restriction does not survive such relicensing or conveying.</p>\n	<p>\n		If you add terms to a covered work in accord with this section, you must place, in the relevant source files, a statement of the additional terms that apply to those files, or a notice indicating where to find the applicable terms.</p>\n	<p>\n		Additional terms, permissive or non-permissive, may be stated in the form of a separately written license, or stated as exceptions; the above requirements apply either way.</p>\n	<h4>\n		8. Termination.</h4>\n	<p>\n		You may not propagate or modify a covered work except as expressly provided under this License. Any attempt otherwise to propagate or modify it is void, and will automatically terminate your rights under this License (including any patent licenses granted under the third paragraph of section 11).</p>\n	<p>\n		However, if you cease all violation of this License, then your license from a particular copyright holder is reinstated (a) provisionally, unless and until the copyright holder explicitly and finally terminates your license, and (b) permanently, if the copyright holder fails to notify you of the violation by some reasonable means prior to 60 days after the cessation.</p>\n	<p>\n		Moreover, your license from a particular copyright holder is reinstated permanently if the copyright holder notifies you of the violation by some reasonable means, this is the first time you have received notice of violation of this License (for any work) from that copyright holder, and you cure the violation prior to 30 days after your receipt of the notice.</p>\n	<p>\n		Termination of your rights under this section does not terminate the licenses of parties who have received copies or rights from you under this License. If your rights have been terminated and not permanently reinstated, you do not qualify to receive new licenses for the same material under section 10.</p>\n	<h4>\n		9. Acceptance Not Required for Having Copies.</h4>\n	<p>\n		You are not required to accept this License in order to receive or run a copy of the Program. Ancillary propagation of a covered work occurring solely as a consequence of using peer-to-peer transmission to receive a copy likewise does not require acceptance. However, nothing other than this License grants you permission to propagate or modify any covered work. These actions infringe copyright if you do not accept this License. Therefore, by modifying or propagating a covered work, you indicate your acceptance of this License to do so.</p>\n	<h4>\n		10. Automatic Licensing of Downstream Recipients.</h4>\n	<p>\n		Each time you convey a covered work, the recipient automatically receives a license from the original licensors, to run, modify and propagate that work, subject to this License. You are not responsible for enforcing compliance by third parties with this License.</p>\n	<p>\n		An &ldquo;entity transaction&rdquo; is a transaction transferring control of an organization, or substantially all assets of one, or subdividing an organization, or merging organizations. If propagation of a covered work results from an entity transaction, each party to that transaction who receives a copy of the work also receives whatever licenses to the work the party&#39;s predecessor in interest had or could give under the previous paragraph, plus a right to possession of the Corresponding Source of the work from the predecessor in interest, if the predecessor has it or can get it with reasonable efforts.</p>\n	<p>\n		You may not impose any further restrictions on the exercise of the rights granted or affirmed under this License. For example, you may not impose a license fee, royalty, or other charge for exercise of rights granted under this License, and you may not initiate litigation (including a cross-claim or counterclaim in a lawsuit) alleging that any patent claim is infringed by making, using, selling, offering for sale, or importing the Program or any portion of it.</p>\n	<h4>\n		11. Patents.</h4>\n	<p>\n		A &ldquo;contributor&rdquo; is a copyright holder who authorizes use under this License of the Program or a work on which the Program is based. The work thus licensed is called the contributor&#39;s &ldquo;contributor version&rdquo;.</p>\n	<p>\n		A contributor&#39;s &ldquo;essential patent claims&rdquo; are all patent claims owned or controlled by the contributor, whether already acquired or hereafter acquired, that would be infringed by some manner, permitted by this License, of making, using, or selling its contributor version, but do not include claims that would be infringed only as a consequence of further modification of the contributor version. For purposes of this definition, &ldquo;control&rdquo; includes the right to grant patent sublicenses in a manner consistent with the requirements of this License.</p>\n	<p>\n		Each contributor grants you a non-exclusive, worldwide, royalty-free patent license under the contributor&#39;s essential patent claims, to make, use, sell, offer for sale, import and otherwise run, modify and propagate the contents of its contributor version.</p>\n	<p>\n		In the following three paragraphs, a &ldquo;patent license&rdquo; is any express agreement or commitment, however denominated, not to enforce a patent (such as an express permission to practice a patent or covenant not to sue for patent infringement). To &ldquo;grant&rdquo; such a patent license to a party means to make such an agreement or commitment not to enforce a patent against the party.</p>\n	<p>\n		If you convey a covered work, knowingly relying on a patent license, and the Corresponding Source of the work is not available for anyone to copy, free of charge and under the terms of this License, through a publicly available network server or other readily accessible means, then you must either (1) cause the Corresponding Source to be so available, or (2) arrange to deprive yourself of the benefit of the patent license for this particular work, or (3) arrange, in a manner consistent with the requirements of this License, to extend the patent license to downstream recipients. &ldquo;Knowingly relying&rdquo; means you have actual knowledge that, but for the patent license, your conveying the covered work in a country, or your recipient&#39;s use of the covered work in a country, would infringe one or more identifiable patents in that country that you have reason to believe are valid.</p>\n	<p>\n		If, pursuant to or in connection with a single transaction or arrangement, you convey, or propagate by procuring conveyance of, a covered work, and grant a patent license to some of the parties receiving the covered work authorizing them to use, propagate, modify or convey a specific copy of the covered work, then the patent license you grant is automatically extended to all recipients of the covered work and works based on it.</p>\n	<p>\n		A patent license is &ldquo;discriminatory&rdquo; if it does not include within the scope of its coverage, prohibits the exercise of, or is conditioned on the non-exercise of one or more of the rights that are specifically granted under this License. You may not convey a covered work if you are a party to an arrangement with a third party that is in the business of distributing software, under which you make payment to the third party based on the extent of your activity of conveying the work, and under which the third party grants, to any of the parties who would receive the covered work from you, a discriminatory patent license (a) in connection with copies of the covered work conveyed by you (or copies made from those copies), or (b) primarily for and in connection with specific products or compilations that contain the covered work, unless you entered into that arrangement, or that patent license was granted, prior to 28 March 2007.</p>\n	<p>\n		Nothing in this License shall be construed as excluding or limiting any implied license or other defenses to infringement that may otherwise be available to you under applicable patent law.</p>\n	<h4>\n		12. No Surrender of Others&#39; Freedom.</h4>\n	<p>\n		If conditions are imposed on you (whether by court order, agreement or otherwise) that contradict the conditions of this License, they do not excuse you from the conditions of this License. If you cannot convey a covered work so as to satisfy simultaneously your obligations under this License and any other pertinent obligations, then as a consequence you may not convey it at all. For example, if you agree to terms that obligate you to collect a royalty for further conveying from those to whom you convey the Program, the only way you could satisfy both those terms and this License would be to refrain entirely from conveying the Program.</p>\n	<h4>\n		13. Use with the GNU Affero General Public License.</h4>\n	<p>\n		Notwithstanding any other provision of this License, you have permission to link or combine any covered work with a work licensed under version 3 of the GNU Affero General Public License into a single combined work, and to convey the resulting work. The terms of this License will continue to apply to the part which is the covered work, but the special requirements of the GNU Affero General Public License, section 13, concerning interaction through a network will apply to the combination as such.</p>\n	<h4>\n		14. Revised Versions of this License.</h4>\n	<p>\n		The Free Software Foundation may publish revised and/or new versions of the GNU General Public License from time to time. Such new versions will be similar in spirit to the present version, but may differ in detail to address new problems or concerns.</p>\n	<p>\n		Each version is given a distinguishing version number. If the Program specifies that a certain numbered version of the GNU General Public License &ldquo;or any later version&rdquo; applies to it, you have the option of following the terms and conditions either of that numbered version or of any later version published by the Free Software Foundation. If the Program does not specify a version number of the GNU General Public License, you may choose any version ever published by the Free Software Foundation.</p>\n	<p>\n		If the Program specifies that a proxy can decide which future versions of the GNU General Public License can be used, that proxy&#39;s public statement of acceptance of a version permanently authorizes you to choose that version for the Program.</p>\n	<p>\n		Later license versions may give you additional or different permissions. However, no additional obligations are imposed on any author or copyright holder as a result of your choosing to follow a later version.</p>\n	<h4>\n		15. Disclaimer of Warranty.</h4>\n	<p>\n		THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM &ldquo;AS IS&rdquo; WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.</p>\n	<h4>\n		16. Limitation of Liability.</h4>\n	<p>\n		IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.</p>\n	<h4>\n		17. Interpretation of Sections 15 and 16.</h4>\n	<p>\n		If the disclaimer of warranty and limitation of liability provided above cannot be given local legal effect according to their terms, reviewing courts shall apply local law that most closely approximates an absolute waiver of all civil liability in connection with the Program, unless a warranty or assumption of liability accompanies a copy of the Program in return for a fee.</p>\n	<p>\n		END OF TERMS AND CONDITIONS</p>\n	<h3>\n		How to Apply These Terms to Your New Programs</h3>\n	<p>\n		If you develop a new program, and you want it to be of the greatest possible use to the public, the best way to achieve this is to make it free software which everyone can redistribute and change under these terms.</p>\n	<p>\n		To do so, attach the following notices to the program. It is safest to attach them to the start of each source file to most effectively state the exclusion of warranty; and each file should have at least the &ldquo;copyright&rdquo; line and a pointer to where the full notice is found.</p>\n	<pre>\n    &lt;one line to give the program&#39;s name and a brief idea of what it does.&gt;\n    Copyright (C) &lt;year&gt;  &lt;name of author&gt;\n\n    This program is free software: you can redistribute it and/or modify\n    it under the terms of the GNU General Public License as published by\n    the Free Software Foundation, either version 3 of the License, or\n    (at your option) any later version.\n\n    This program is distributed in the hope that it will be useful,\n    but WITHOUT ANY WARRANTY; without even the implied warranty of\n    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n    GNU General Public License for more details.\n\n    You should have received a copy of the GNU General Public License\n    along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.\n</pre>\n	<p>\n		Also add information on how to contact you by electronic and paper mail.</p>\n	<p>\n		If the program does terminal interaction, make it output a short notice like this when it starts in an interactive mode:</p>\n	<pre>\n    &lt;program&gt;  Copyright (C) &lt;year&gt;  &lt;name of author&gt;\n    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w&#39;.\n    This is free software, and you are welcome to redistribute it\n    under certain conditions; type `show c&#39; for details.\n</pre>\n	<p>\n		The hypothetical commands `show w&#39; and `show c&#39; should show the appropriate parts of the General Public License. Of course, your program&#39;s commands might be different; for a GUI interface, you would use an &ldquo;about box&rdquo;.</p>\n	<p>\n		You should also get your employer (if you work as a programmer) or school, if any, to sign a &ldquo;copyright disclaimer&rdquo; for the program, if necessary. For more information on this, and how to apply and follow the GNU GPL, see &lt;<a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/</a>&gt;.</p>\n	<p>\n		The GNU General Public License does not permit incorporating your program into proprietary programs. If your program is a subroutine library, you may consider it more useful to permit linking proprietary applications with the library. If this is what you want to do, use the GNU Lesser General Public License instead of this License. But first, please read &lt;<a href="http://www.gnu.org/philosophy/why-not-lgpl.html">http://www.gnu.org/philosophy/why-not-lgpl.html</a>&gt;.</p>\n</div>\n<p>\n	&nbsp;</p>\n', 1, '/license', 'en', 'taracot', 1354542533);

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
) ENGINE=MyISAM AUTO_INCREMENT=29 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=80 AUTO_INCREMENT=29 ;

-- 
-- Dumping data for table `taracot_settings`
-- 

INSERT INTO `taracot_settings` VALUES (1, 'site_title', 'Taracot CMS', '', 'en', 1358181002);
INSERT INTO `taracot_settings` VALUES (7, 'site_description', 'This is the global site description', '', 'en', 1350564084);
INSERT INTO `taracot_settings` VALUES (8, 'catalog_title_cat2', 'Ну вот и что за нафиг?', '<p>\n	РћС‚Р°РєРµ С…СѓР№РЅСЏ, РјР°Р»СЏС‚Р°. РўР°РєРёРµ РґРµР»Р°, СЂРµР±СЏС‚РєРё.<br></p>\n', 'en', 1352462803);
INSERT INTO `taracot_settings` VALUES (6, 'site_keywords', 'these, are, global, site, keywords', '', 'en', 1350564057);
INSERT INTO `taracot_settings` VALUES (9, 'billing_plan_name_profi', 'Professional', '', 'en', 1353505539);
INSERT INTO `taracot_settings` VALUES (10, 'billing_plan_cost_profi', '550', '', '', 1355838493);
INSERT INTO `taracot_settings` VALUES (11, 'billing_plan_name_econom', 'Econom', '', 'en', 1353589907);
INSERT INTO `taracot_settings` VALUES (12, 'billing_history_domainupdate', 'Domain update', '', 'en', 1353870098);
INSERT INTO `taracot_settings` VALUES (13, 'billing_history_domainregister', 'Domain registration', '', 'en', 1353870392);
INSERT INTO `taracot_settings` VALUES (14, 'billing_service_name_vps', 'VPS management', '', 'en', 1354698743);
INSERT INTO `taracot_settings` VALUES (15, 'billing_service_cost_vps', '123', '', '', 1354698726);
INSERT INTO `taracot_settings` VALUES (16, 'billing_service_name_backup', 'Managed backup', '', 'en', 1354701386);
INSERT INTO `taracot_settings` VALUES (17, 'billing_service_cost_backup', '666', '', '', 1354701407);
INSERT INTO `taracot_settings` VALUES (18, 'billing_currency', 'RUR', '', 'en', 1355609052);
INSERT INTO `taracot_settings` VALUES (19, 'billing_payment_webmoney', 'Webmoney', '<p>\n	A multifunctional payment tool that provides secure and immediate transactions online</p>\n', 'en', 1355232452);
INSERT INTO `taracot_settings` VALUES (20, 'billing_payment_robokassa', 'Robokassa', '<p>\n	Payments in every e-currency, using mobile commerce services (MTS, Megafon, Beeline), e-invoicing via leading banks in Russia, through ATMs, through instant payment terminals, through Contact remittances, and with the iPhone application</p>\n', 'en', 1355232538);
INSERT INTO `taracot_settings` VALUES (21, 'billing_history_addfunds', 'Funds deposit', '', 'en', 1355393623);
INSERT INTO `taracot_settings` VALUES (22, 'billing_plan_cost_econom', '199', '', '', 1355593214);
INSERT INTO `taracot_settings` VALUES (23, 'billing_history_hostingupdate', 'Hosting account update', '', 'en', 1355656040);
INSERT INTO `taracot_settings` VALUES (24, 'billing_domain_zone_ru', '500,400', '', '', 1355837400);
INSERT INTO `taracot_settings` VALUES (25, 'billing_domain_zone_com', '500', '', '', 1355837411);
INSERT INTO `taracot_settings` VALUES (26, 'billing_nss_ns1', 'ns1.re-hash.org', '', '', 1357642095);
INSERT INTO `taracot_settings` VALUES (27, 'billing_nss_ns2', 'ns2.re-hash.org', '', '', 1357642114);
INSERT INTO `taracot_settings` VALUES (28, 'blog_hubs', 'test,Тестовый хаб;site,Новости сайта;misc,Разные записи', '', 'en', 1374575717);

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
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=82 AUTO_INCREMENT=11 ;

-- 
-- Dumping data for table `taracot_users`
-- 

INSERT INTO `taracot_users` VALUES (1, 'admin', '6442e843969ddd1299860e447a593b4f', 0, 'Medved', 'xtreme@rh1.ru', '79217998111', 'blog_admin', 2, '', NULL, 'en', 1375267187);
INSERT INTO `taracot_users` VALUES (9, 'medved', '401568e9e2faae21d0341397972cd10b', 0, '', 'medved@medved.com', '', NULL, 1, '', NULL, NULL, 1357033313);
