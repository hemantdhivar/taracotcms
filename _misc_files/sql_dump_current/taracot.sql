-- phpMyAdmin SQL Dump
-- version 2.6.1
-- http://www.phpmyadmin.net
-- 
-- Хост: localhost
-- Время создания: Янв 23 2014 г., 19:01
-- Версия сервера: 5.0.45
-- Версия PHP: 5.2.4
-- 
-- БД: `taracot`
-- 

-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_blog_comments`
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
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

-- 
-- Дамп данных таблицы `taracot_blog_comments`
-- 

INSERT INTO `taracot_blog_comments` VALUES (1, 1, 1, 'xtreme', 'phuck', 1388052290, 'f705393301e2b6f31b13ffb706f0dcd9', 1, 4, 1, '127.0.0.1');
INSERT INTO `taracot_blog_comments` VALUES (2, 2, 0, 'xtreme', 'Test comment', 1390386163, '1fdcde040c470c71fe4f5c1dba34ec42', 1, 4, 1, '127.0.0.1');

-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_blog_posts`
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
  FULLTEXT KEY `ptags` (`ptags`),
  FULLTEXT KEY `ptitle` (`ptitle`,`ptext`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=3 ;

-- 
-- Дамп данных таблицы `taracot_blog_posts`
-- 

INSERT INTO `taracot_blog_posts` VALUES (1, 'en', 'xtreme', 'test', 0, 'Test post', 'test, record', 1387972464, 'de2b69e2d3962cf2a33917ede62cd095', 'По его словам, решение возобновить производство по делу связано с постановлением Европейского суда по правам человека, который указал на многочисленные нарушения прав подсудимых, допущенных в ходе процесса. С юридической точки зрения решение ЕСПЧ считается вновь открывшимися обстоятельствами, [b]на основании[/b] которых решение по делу может быть пересмотрено.\nКроме того, глава Верховного суда отменил решение судьи, отказавшего Ходорковскому и его деловому партнеру в рассмотрении надзорных жалоб на приговор по второму делу в их отношении. Теперь эти жалобы поступят на рассмотрение президиума Верховного суда. Адвокаты осужденных выразили удовлетворение решением Вячеслава Лебедева, но не стали оценивать перспективы дела.', 'По его словам, решение возобновить производство по&nbsp;делу связано с&nbsp;постановлением Европейского суда по&nbsp;правам человека, который указал на&nbsp;многочисленные нарушения прав подсудимых, допущенных в&nbsp;ходе процесса. С юридической точки зрения решение ЕСПЧ считается вновь открывшимися обстоятельствами, <b>на&nbsp;основании</b> которых решение по&nbsp;делу может быть пересмотрено.<br />\nКроме того, глава Верховного суда отменил решение судьи, отказавшего Ходорковскому и&nbsp;его деловому партнеру в&nbsp;рассмотрении надзорных жалоб на&nbsp;приговор по&nbsp;второму делу в&nbsp;их отношении. Теперь эти жалобы поступят на&nbsp;рассмотрение президиума Верховного суда. Адвокаты осужденных выразили удовлетворение решением Вячеслава Лебедева, но&nbsp;не стали оценивать перспективы дела.', 0, 'По его словам, решение возобновить производство по&nbsp;делу связано с&nbsp;постановлением Европейского суда по&nbsp;правам человека, который указал на&nbsp;многочисленные нарушения прав подсудимых, допущенных в&nbsp;ходе процесса. С юридической точки зрения решение ЕСПЧ считается вновь открывшимися обстоятельствами, <b>на&nbsp;основании</b> которых решение по&nbsp;делу может быть пересмотрено.<br />\nКроме того, глава Верховного суда отменил решение судьи, отказавшего Ходорковскому и&nbsp;его деловому партнеру в&nbsp;рассмотрении надзорных жалоб на&nbsp;приговор по&nbsp;второму делу в&nbsp;их отношении. Теперь эти жалобы поступят на&nbsp;рассмотрение президиума Верховного суда. Адвокаты осужденных выразили удовлетворение решением Вячеслава Лебедева, но&nbsp;не стали оценивать перспективы дела.', 83, 1, '127.0.0.1', 0, 0, 1, 1389268053);
INSERT INTO `taracot_blog_posts` VALUES (2, 'en', 'xtreme', 'test', 1, 'Test post', 'test', 1390382891, 'd5d99aa0dd06f3454750c57dfef29e9a', 'В следующих статьях мы расскажем про то, как поднять Elliptics в домашних условиях и примеры его использования, подробнее про устройство Eblob’а [cut](поверьте, нам есть что о нем интересного рассказать), стриминг данных, вторичные индексы и многое другое.', 'В следующих статьях мы расскажем про то, как поднять Elliptics в домашних условиях и примеры его использования, подробнее про устройство Eblob’а ', 1, 'В следующих статьях мы расскажем про&nbsp;то, как&nbsp;поднять Elliptics в&nbsp;домашних условиях и&nbsp;примеры его использования, подробнее про&nbsp;устройство Eblob’а &#40;поверьте, нам есть что о&nbsp;нем интересного рассказать&#41;, стриминг данных, вторичные индексы и&nbsp;многое другое.', 161, 1, '127.0.0.1', 0, 0, 1, 1390385924);

-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_catalog`
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
-- Дамп данных таблицы `taracot_catalog`
-- 


-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_firewall`
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
-- Дамп данных таблицы `taracot_firewall`
-- 


-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_pages`
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
-- Дамп данных таблицы `taracot_pages`
-- 

INSERT INTO `taracot_pages` VALUES (1, 'Home page', 'home', 'Home page', '<h1>Installation successful</h1>\n\n<p>As you can read this text, the installation seems to be sucessful.</p>\n', 1, '/', 'en', 'taracot', 1381929585);

-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_search_db`
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
-- Дамп данных таблицы `taracot_search_db`
-- 

INSERT INTO `taracot_search_db` VALUES ('pages', 1, 'en', 'Home page', 'As you can read this text, the installation seems to be sucessful.', 'sucessful the you page seems installation can to as be text read home this', '/', 1381929585);
INSERT INTO `taracot_search_db` VALUES ('blog', 2, 'en', 'Test post', 'В следующих статьях мы расскажем про то, как поднять Elliptics в домашних условиях и примеры его использования, подробнее про устройство Eblob’а (поверьте, нам есть что о&...', 'elliptics как поднять другое eblobа рассказать test в домашних нам есть использования что поверьте post в индексы следующих и примеры стриминг и многое данных условиях подробнее вторичные статьях его про то интересного мы о нем про устройство расскажем', '/blog/post/2', 1390385924);

-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_settings`
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
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=cp1251 AUTO_INCREMENT=6 ;

-- 
-- Дамп данных таблицы `taracot_settings`
-- 

INSERT INTO `taracot_settings` VALUES (1, 'site_title', 'Taracot CMS', '', 'en', 1358181002);
INSERT INTO `taracot_settings` VALUES (2, 'site_description', 'Taracot CMS installation is running', '', 'en', 1376571472);
INSERT INTO `taracot_settings` VALUES (3, 'site_keywords', 'taracot cms, perl, dancer', '', 'en', 1376571477);
INSERT INTO `taracot_settings` VALUES (4, 'support_topics', 'sample,Sample topic;misc,Misc topic', '', 'en', 1381928970);
INSERT INTO `taracot_settings` VALUES (5, 'blog_hubs', 'test,The Test Hub', '', 'en', 1387894140);

-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_support`
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
-- Дамп данных таблицы `taracot_support`
-- 


-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_support_ans`
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
-- Дамп данных таблицы `taracot_support_ans`
-- 


-- --------------------------------------------------------

-- 
-- Структура таблицы `taracot_users`
-- 

CREATE TABLE `taracot_users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(100) NOT NULL,
  `username_social` varchar(100) default NULL,
  `username_unset` tinyint(1) default '0',
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
-- Дамп данных таблицы `taracot_users`
-- 

INSERT INTO `taracot_users` VALUES (1, 'xtreme', NULL, 1, '0f5559ee359fba749e7e6638fcfdbbfb', 1, 'Michael Matveev', '', NULL, NULL, '79217998111', 'blog_post, blog_moderator, blog_moderator_test1', 2, NULL, 1376300791, 'en', 0, 0, 1390481259);
INSERT INTO `taracot_users` VALUES (2, 'user', NULL, 0, '1d88c84caa93404ecf250399bc1be5a0', 1, 'John Doe', '', NULL, NULL, '79217998111', '', 1, NULL, NULL, 'en', 1376731887, 0, 1379770337);
