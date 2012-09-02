# ************************************************************
# Sequel Pro SQL dump
# Version 3408
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.5.25a)
# Database: glacier-test
# Generation Time: 2012-09-02 19:19:05 +0000
# ************************************************************




# Dump of table archives
# ------------------------------------------------------------

CREATE TABLE `archives` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bag_id` int(10) unsigned NOT NULL,
  `archive_id` varchar(200) NOT NULL DEFAULT '',
  `region` varchar(20) NOT NULL DEFAULT '',
  `vault` varchar(200) NOT NULL DEFAULT '',
  `account` varchar(20) NOT NULL DEFAULT '',
  `state` enum('active','deleted') NOT NULL DEFAULT 'active',
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table bags
# ------------------------------------------------------------

CREATE TABLE `bags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `directory_id` int(10) unsigned NOT NULL,
  `directory_hash` varchar(32) NOT NULL DEFAULT '',
  `manifest` varchar(200) NOT NULL DEFAULT '',
  `file_name` varchar(200) NOT NULL DEFAULT '',
  `file_hash` varchar(64) NOT NULL DEFAULT '',
  `file_size` bigint(11) unsigned NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `directory_id` (`directory_id`),
  KEY `directory_hash` (`directory_hash`),
  KEY `manifest` (`manifest`),
  KEY `file_hash` (`file_hash`),
  KEY `unique-id-hash` (`directory_id`,`directory_hash`,`file_hash`)
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



# Dump of table archive_events
# ------------------------------------------------------------

CREATE TABLE `archive_events` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `archive_id` int(11) unsigned NOT NULL,
  `event_type` enum('upload','retrieval','audit','deletion') NOT NULL DEFAULT 'upload',
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  `result` enum('success','failure') NOT NULL DEFAULT 'success',
  PRIMARY KEY (`id`),
  KEY `subject_id` (`archive_id`),
  KEY `event_type` (`event_type`),
  KEY `result` (`result`),
  KEY `start` (`start`),
  KEY `end` (`end`)
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




