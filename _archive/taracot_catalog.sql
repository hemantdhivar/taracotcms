-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Jul 17, 2013 at 02:51 PM
-- Server version: 5.0.45
-- PHP Version: 5.2.4
-- 
-- Database: `taracot`
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
  `description_short` varchar(2048) default NULL,
  `content` text,
  `status` tinyint(4) default '1',
  `filename` varchar(255) NOT NULL,
  `groupid` varchar(80) default NULL,
  `lang` varchar(5) default 'en',
  `layout` varchar(40) NOT NULL default 'taracot',
  `special_flag` tinyint(1) default '0',
  `lastchanged` int(11) default '0',
  UNIQUE KEY `id` (`id`),
  FULLTEXT KEY `filter` (`pagetitle`,`filename`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=76 AUTO_INCREMENT=12 ;

-- 
-- Dumping data for table `taracot_catalog`
-- 

INSERT INTO `taracot_catalog` VALUES (11, 'Test2', 'cat1', 'url2', '', '<p>\n	dfsdfdfdsf</p>\n', 2, '/test11', 'cat2', 'en', 'taracot', 0, 1358178220);
