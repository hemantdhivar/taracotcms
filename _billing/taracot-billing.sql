-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Aug 06, 2013 at 05:19 PM
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

