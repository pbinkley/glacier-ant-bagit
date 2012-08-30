glacier-ant-bagit
=================

Ant script to create bags and upload them to Amazon Glacier

It works at the directory level: for the specified directory, it creates a bag i
and tars it, then uploads the tar file to the specified vault. 
[Bagit](https://wiki.ucop.edu/display/Curation/BagIt) is a 
specification for creating, managing and verifying manifests of groups of files.
Since Glacier is intended for long term preservation, it makes sense to 
package the files in a self-verifying wrapper before uploading them.

## Platform

Developed and tested on OS/X Mountain Lion so far. I'll be testing on Ubuntu 
shortly. It's all Java, so it should run anywhere Ant can run.

## Installation

Copy build.properties.TEMPLATE to build.properties. Edit it to provide 
the Glacier region and vault name you'll be uploding to, and also 
the path to your Maven executable (/usr/bin/mvn on the Mac). Maven is needed to 
build the glacier-cli package.

In the home directory, run "ant -f build-install.xml". This will create a lib 
directory and download various dependencies and copy them into it.

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

## Running

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

## Output

The various tasks will write log files into the logs directories. A CSV file of all uploads will be created in the upload-logs directory (one CSV for each 
region/vault pair). The CSV fields are:

timestamp, directory name, file name, file length, SHA-256 checksum, region, vault, archive ID, start time, end time

Subsequent runs will append to the appropriate CSV file.

The Bagit manifest is copied into the "manifests" directory with a name that combines a sanitized
version of the source directory path (with separators replaced by underscores) plus
the region, vault and timestamp of the job run. This provides a record of all the files in the bag,
with their md5 hashes.