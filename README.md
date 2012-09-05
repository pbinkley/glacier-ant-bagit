glacier-ant-bagit
=================

Ant script to create bags and upload them to Amazon Glacier

It works at the directory level: for the specified directory, it creates a bag 
and tars it, then uploads the tar file to the specified vault. 
[Bagit](https://wiki.ucop.edu/display/Curation/BagIt) is a 
specification for creating, managing and verifying manifests of groups of files.
Since Glacier is intended for long term preservation, it makes sense to 
package the files in a self-verifying wrapper before uploading them.

v0.2 includes a mysql tracking database and a workflow that uses it to 
drive the creation and uploading of archives for a specified set of directories.

For background see [my blog](http://www.wallandbinkley.com/quaedam/2012/08_29_getting-serious-with-amazon-glacier.html).

## Platform

Developed and tested on OS/X Mountain Lion and Ubunto so far. It's all Java, so it should run anywhere Ant can run. 
That said, v0.2 uses the unix utility "du" to determine the total size of a directory. No doubt
Cygwin or some other utility could be used in a Windows environment.

## Installation

Copy build.properties.TEMPLATE to build.properties. Edit it to provide 
the Glacier region and vault name you'll be uploding to, and also 
the path to your Maven executable (/usr/bin/mvn on the Mac). Maven is needed to 
build the glacier-cli package.

In the home directory, run "ant -f build-install.xml". This will create a lib 
directory and download various dependencies and copy them into it. If you 
are upgrading from an earlier version, run this again to install new jar files 
(for mysql).

Create a MySQL database and a user with full permissions on it. Put the details of
db and user in the build.properties:

-db.driver=com.mysql.jdbc.Driver
-db.url=jdbc:mysql://localhost:3306/glacier
-db.user=glacier
-db.password=xxxxxxxxxx

Run "ant -f build-install.xml db.create" to create the tables within this database
(from sql/db-structure.sql).


Dependencies:

- [Library of Congress Bagit toolkit](http://sourceforge.net/projects/loc-xferutils/): 
- [ant-contrib](http://ant-contrib.sourceforge.net/)
- [carlossg/glacier-cli](https://github.com/carlossg/glacier-cli). I've 
[forked](https://github.com/pbinkley/glacier-cli) this project just so I 
could tag the current version for downloading.

Finally, create a file AwsCredentials.properties in your user's home directory
(not the script's home directory) to be used by glacier-cli, like this:

     accessKey=xxxxxxxxxxxxxxxxxxxxxxxxx
     secretKey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

## Testing

Run "ant test" to do a test upload with a small bag. 

To upload real content, you must provide the path to the directory containing 
the source files, and optionally the name of the tar file that will be created 
and uploaded. It seems like a good idea to make the tar file name meaningful, 
since if your local metadata is lost, that will be the only way to identify
the archives in the vault. These values are passed as parameters like this:

ant -Ddir.source=/User/peterbinkley/Pictures/some-pix -Dtarfile=temp/some-pix.tar run

The region and vault are set in the build.properties file, or can be overridden
on the command line with "-Daws.region=xxxx" or "-Daws.vaultName=xxxx". 

The script will show you what it is going to do, and give you 15 seconds to hit ctrl-C if you don't like it.

## Test Output

The various tasks will write log files into the logs directories. A CSV file of all uploads will be created in the upload-logs directory (one CSV for each 
region/vault pair). The CSV fields are:

timestamp, directory name, file name, file length, SHA-256 checksum, region, vault, archive ID, start time, end time

Subsequent runs will append to the appropriate CSV file.

The Bagit manifest is copied into the "manifests" directory with a name that combines a sanitized
version of the source directory path (with separators replaced by underscores) plus
the region, vault and timestamp of the job run. This provides a record of all the files in the bag,
with their md5 hashes.

## Running

The use of the tracking db in v0.2 enables a three-step workflow, suitable
for automating in cron jobs.

- add-directories: discover directories in a specified location and add them 
to the "directories" table.
- find-uploadables: with a sql query, discover directories that do not yet have 
an archive in Glacier or whose content has changed since their last archive was
uploaded, and add them to the upload_queue table.
- take-off-upload-queue: retrieve the earliest item from the upload_queue table,
process it in full (create bag and upload it), and delete it from the upload_queue.

I'm imagining a workflow that based on cron jobs: a daily job that would add directories from 
e.g. a My Pictures directory, followed by a find-uploadables job that would update the queue
with directories that need archiving; and separate, frequent cron job that would take a 
directory off the queue and upload it.

Add-directories options:

-dir.watch: the directory within which to look for directories to upload
-dirset: an Ant dirset specification to select candidate diretories: e.g. "*" 
for all subdirectories, "*/*" for all subsubdirectories, "pix*", "singledirectory", etc.

## Output

Here's a test run, using only the testcontent directory within the root directory. 
After each job, the effects in the Mysql tables are shown.

```
peter@panther:/panther_raid/peter/glacier-ant-bagit$ ant -Ddir.watch=. -Ddirset=testcontent db.add-directories
Unable to locate tools.jar. Expected to find it in /usr/lib/jvm/java-6-openjdk-i386/lib/tools.jar
Buildfile: /panther_raid/peter/glacier-ant-bagit/build.xml

db.add-directories:
     [echo] Directories: 1

check.empty:
     [echo] Checking /panther_raid/peter/glacier-ant-bagit/testcontent
     [echo] Empty? ${empty}

db.add-directory:
    [mkdir] Created dir: /panther_raid/peter/glacier-ant-bagit/temp/directory-hash
     [echo] path: /panther_raid/peter/glacier-ant-bagit/testcontent
     [echo] size: 20
     [echo] directory_hash: 98022cae439ef47d34ed329b271a28d1
     [echo] 
     [echo]          insert into directories
     [echo]          (path, size, directory_hash, added)
     [echo]          values ("/panther_raid/peter/glacier-ant-bagit/testcontent", 20, "98022cae439ef47d34ed329b271a28d1", NOW())
     [echo]          on duplicate key update 
     [echo]          size=VALUES(size),
     [echo]          directory_hash=VALUES(directory_hash),
     [echo]          updated=NOW();
     [echo]       
      [sql] Executing commands
      [sql] 1 rows affected
      [sql] 1 of 1 SQL statements executed successfully
     [echo] Error? ${sql-error}

peter@panther:/panther_raid/peter/glacier-ant-bagit$ mysql -u glacier -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 245
Server version: 5.5.24-0ubuntu0.12.04.1 (Ubuntu)

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use glacier;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select * from directories;
+----+---------------------------------------------------+------+----------------------------------+---------------------+---------+
| id | path                                              | size | directory_hash                   | added               | updated |
+----+---------------------------------------------------+------+----------------------------------+---------------------+---------+
|  1 | /panther_raid/peter/glacier-ant-bagit/testcontent |   20 | 98022cae439ef47d34ed329b271a28d1 | 2012-09-04 18:59:24 | NULL    |
+----+---------------------------------------------------+------+----------------------------------+---------------------+---------+
1 row in set (0.00 sec)




peter@panther:/panther_raid/peter/glacier-ant-bagit$ ant db.find-uploadables
Unable to locate tools.jar. Expected to find it in /usr/lib/jvm/java-6-openjdk-i386/lib/tools.jar
Buildfile: /panther_raid/peter/glacier-ant-bagit/build.xml

db.find-uploadables:
      [sql] Executing commands
      [sql] 1 of 1 SQL statements executed successfully
     [echo] Rows: 0

db.add-to-upload-queue:
     [echo] 1,98022cae439ef47d34ed329b271a28d1
     [echo] 
     [echo]          directory_id: 1
     [echo]          directory_hash: 98022cae439ef47d34ed329b271a28d1
     [echo]          go: true
     [echo]       

db.add-to-upload-queue-sql:
      [sql] Executing commands
      [sql] 1 rows affected
      [sql] 1 of 1 SQL statements executed successfully

BUILD SUCCESSFUL
Total time: 11 seconds




peter@panther:/panther_raid/peter/glacier-ant-bagit$ mysql -u glacier -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 245
Server version: 5.5.24-0ubuntu0.12.04.1 (Ubuntu)

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use glacier;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed

mysql> select * from upload_queue;
+----+--------------+----------------------------------+---------------------+---------+
| id | directory_id | directory_hash                   | added               | claimed |
+----+--------------+----------------------------------+---------------------+---------+
|  1 |            1 | 98022cae439ef47d34ed329b271a28d1 | 2012-09-04 19:02:06 | NULL    |
+----+--------------+----------------------------------+---------------------+---------+
1 row in set (0.00 sec)


peter@panther:/panther_raid/peter/glacier-ant-bagit$ ant db.take-off-upload-queue
Unable to locate tools.jar. Expected to find it in /usr/lib/jvm/java-6-openjdk-i386/lib/tools.jar
Buildfile: /panther_raid/peter/glacier-ant-bagit/build.xml

db.take-off-upload-queue:
      [sql] Executing commands
      [sql] 2 of 2 SQL statements executed successfully
     [echo] Rows: 1
     [echo] 
     [echo]          results: 1,/panther_raid/peter/glacier-ant-bagit/testcontent
     [echo] 
     [echo] 
     [echo]          directory_id: 1
     [echo]          directory_hash: /panther_raid/peter/glacier-ant-bagit/testcontent
     [echo]          go: true
     [echo]       

db.take-off-upload-queue-run:

init:

run:
     [echo] 
     [echo]          Job 2012-09-04T19-25-16-0600
     [echo]          
     [echo]          Source:    /panther_raid/peter/glacier-ant-bagit/testcontent
     [echo]          Bag:       /panther_raid/peter/glacier-ant-bagit/temp/bag
     [echo]          File name: /panther_raid/peter/glacier-ant-bagit/temp/bag.tar
     [echo]          Region:    us-west-2
     [echo]          Vault:     test
     [echo]          
     [echo]          Kill me now if that's wrong!
     [echo]       

init:

cleanup:
   [delete] Deleting directory /panther_raid/peter/glacier-ant-bagit/temp
    [mkdir] Created dir: /panther_raid/peter/glacier-ant-bagit/temp

init:

bagit-create:

init:

bagit-verify:
     [echo] Logfile: /panther_raid/peter/glacier-ant-bagit/logs/bagit-verify-2012-09-04-19-25-16-214.log

init:

copy-manifest:
     [echo] Manifest: _panther_raid_peter_glacier-ant-bagit_testcontent_us-west-2_test_2012-09-04-19-25-16-214.txt
     [copy] Copying 1 file to /panther_raid/peter/glacier-ant-bagit/manifests

init:

tar:
      [tar] Building tar: /panther_raid/peter/glacier-ant-bagit/temp/bag.tar
     [echo] 20f30b6fe5b7cf9604b992d910961b99c44370856ae4ffd68a2b880d1c7e3275

init:

register-bag:
    [mkdir] Created dir: /panther_raid/peter/glacier-ant-bagit/temp/directory-hash
     [echo] 20f30b6fe5b7cf9604b992d910961b99c44370856ae4ffd68a2b880d1c7e3275
      [sql] Executing commands
      [sql] 2 rows affected
      [sql] 1 rows affected
      [sql] 2 of 2 SQL statements executed successfully
     [echo] Error? ${sql-error}

init:

glacier-upload:
     [echo] Logfile: /panther_raid/peter/glacier-ant-bagit/logs/glacier-upload-2012-09-04-19-25-16-214.log
     [echo] Filename: /panther_raid/peter/glacier-ant-bagit/temp/bag.tar
     [echo] File size: 20480
     [echo] Archive ID: nJjqv5rgQsGzliAZDAadaeP6sE8rbTzvF99fX63g_h6OiIsmcOwdyx-ni43mkSIzDlfWD_873zJVGttgzbq3ZWWSQMusY2F0V4gTD_tYVvbJnQf-6CGE1TJw0mJ1mBUhupiHteiXdw
      [sql] Executing commands
      [sql] 1 rows affected
      [sql] 1 rows affected
      [sql] 2 of 2 SQL statements executed successfully
     [echo] Error? ${sql-error}
      [sql] Executing commands
      [sql] 1 of 1 SQL statements executed successfully

BUILD SUCCESSFUL
Total time: 1 minute 27 seconds
peter@panther:/panther_raid/peter/glacier-ant-bagit$ mysql -u glacier -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 257
Server version: 5.5.24-0ubuntu0.12.04.1 (Ubuntu)

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use glacier
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select * from bags;
+----+--------------+----------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------------+------------------------------------------------------------------+-----------+---------------------+
| id | directory_id | directory_hash                   | manifest                                                                                     | file_name                                          | file_hash                                                        | file_size | created             |
+----+--------------+----------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------------+------------------------------------------------------------------+-----------+---------------------+
|  1 |            1 | 98022cae439ef47d34ed329b271a28d1 | _panther_raid_peter_glacier-ant-bagit_testcontent_us-west-2_test_2012-09-04-19-25-16-214.txt | /panther_raid/peter/glacier-ant-bagit/temp/bag.tar | 20f30b6fe5b7cf9604b992d910961b99c44370856ae4ffd68a2b880d1c7e3275 |     20480 | 2012-09-04 19:26:19 |
+----+--------------+----------------------------------+----------------------------------------------------------------------------------------------+----------------------------------------------------+------------------------------------------------------------------+-----------+---------------------+
1 row in set (0.00 sec)

mysql> select * from archives;
+----+--------+--------------------------------------------------------------------------------------------------------------------------------------------+-----------+-------+--------------+--------+---------------------+
| id | bag_id | archive_id                                                                                                                                 | region    | vault | account      | state  | created             |
+----+--------+--------------------------------------------------------------------------------------------------------------------------------------------+-----------+-------+--------------+--------+---------------------+
|  1 |      1 | nJjqv5rgQsGzliAZDAadaeP6sE8rbTzvF99fX63g_h6OiIsmcOwdyx-ni43mkSIzDlfWD_873zJVGttgzbq3ZWWSQMusY2F0V4gTD_tYVvbJnQf-6CGE1TJw0mJ1mBUhupiHteiXdw | us-west-2 | test  | xxxxxxxxxxxx | active | 2012-09-04 19:26:31 |
+----+--------+--------------------------------------------------------------------------------------------------------------------------------------------+-----------+-------+--------------+--------+---------------------+
1 row in set (0.00 sec)

mysql> select * from upload_queue;
Empty set (0.00 sec)

mysql> select * from archive_events;
+----+------------+------------+---------------------+---------------------+---------+
| id | archive_id | event_type | start               | end                 | result  |
+----+------------+------------+---------------------+---------------------+---------+
|  1 |          1 | upload     | 2012-09-04 19:26:20 | 2012-09-04 19:26:30 | success |
+----+------------+------------+---------------------+---------------------+---------+
1 row in set (0.00 sec)
```

## Next steps

- add test harness using AntUnit
- add web interface with Ruby on Rails, to allow monitoring of current actions, look up history of specific directories, add directories, etc. etc.
- add retrieval and deletion jobs: queue archives for retrieval, monitor SNS for alert, download retrieved archive, etc.
- manage versions: set rules for management of previous archives when a directory is re-archived: delete, keep for a specified period, keep specified number of previous version, etc.