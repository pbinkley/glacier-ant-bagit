# ************************************************************
# Sequel Pro SQL dump
# Version 3408
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.5.25a)
# Database: glacier
# Generation Time: 2012-09-01 16:52:43 +0000
# ************************************************************




# Dump of table archives
# ------------------------------------------------------------

CREATE TABLE `archives` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bag_id` int(10) unsigned NOT NULL,
  `archive_id` varchar(200) NOT NULL DEFAULT '',
  `region` varchar(20) NOT NULL DEFAULT '',
  `vault` varchar(200) NOT NULL DEFAULT '',
  `user_id` int(11) unsigned NOT NULL,
  `state` enum('active','deleted') NOT NULL DEFAULT 'active',
  `created` datetime NOT NULL,
  `uploaded` datetime DEFAULT NULL,
  `deleted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table bags
# ------------------------------------------------------------

CREATE TABLE `bags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `directory_id` int(10) unsigned NOT NULL,
  `directory_hash` varchar(32) NOT NULL DEFAULT '',
  `filename` varchar(200) NOT NULL DEFAULT '',
  `created` datetime NOT NULL,
  `size` bigint(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table directories
# ------------------------------------------------------------

CREATE TABLE `directories` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `path` varchar(200) NOT NULL DEFAULT '',
  `size` bigint(20) unsigned NOT NULL,
  `directory_hash` varchar(32) NOT NULL DEFAULT '',
  `added` datetime NOT NULL,
  `updated` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `path` (`path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table events
# ------------------------------------------------------------

CREATE TABLE `events` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `subject_id` int(11) unsigned NOT NULL,
  `subject_type` enum('directory','bag','archive') NOT NULL DEFAULT 'directory',
  `event_type` enum('upload','retrieval','creation','deletion') NOT NULL DEFAULT 'upload',
  `timestamp` datetime NOT NULL,
  `result` enum('success','failure') NOT NULL DEFAULT 'success',
  PRIMARY KEY (`id`),
  KEY `subject_id` (`subject_id`),
  KEY `subject_type` (`subject_type`),
  KEY `event_type` (`event_type`),
  KEY `timestamp` (`timestamp`),
  KEY `result` (`result`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table upload_queue
# ------------------------------------------------------------

CREATE TABLE `upload_queue` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `directory_id` int(10) unsigned NOT NULL,
  `added` datetime NOT NULL,
  `size` bigint(20) unsigned NOT NULL,
  `claimed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `directory_id` (`directory_id`),
  KEY `added` (`added`),
  KEY `claimed` (`claimed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




