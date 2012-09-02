# ************************************************************
# Sequel Pro SQL dump
# Version 3408
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.5.25a)
# Database: glacier-test
# Generation Time: 2012-09-02 16:01:45 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


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
  `manifest` varchar(200) NOT NULL DEFAULT '',
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




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
