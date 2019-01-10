#!/usr/bin/perl
# by Dimitri Ostapenko
# restore is run on the same day as backup, but later of course; 
# use this script on a backup server, run as postgres, or whoever the owner of walkin db is
# 
# N.B! dropdb will fail if db is accessed by other client(s) - stop apache before running! (root cron)
#
#
#This script is different on production(debian) and test(OSX)

use strict;
my $dow = (localtime)[6];
#my $target = '/home/rails/backup/walkin'.$dow.'.gz';
my $target = '/Users/dmitri/emr/pgbackup/walkin'.$dow.'.gz';

print  "This is ", `uname -a`, `date`, " \n";
print "Dropping db 'walkin' \n";
`/usr/local/bin/dropdb --if-exists walkin -e`;
print "Creating db 'walkin'\n";
`/usr/local/bin/createdb walkin`;
print "Restoring DB walkin - full restore from latest backup $target \n";
`/bin/cat  $target | /usr/bin/gunzip | /usr/local/bin/psql walkin`;
