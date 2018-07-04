#!/usr/bin/perl
# by Dimitri Ostapenko
# restore is run on the same day as backup, but later of course; 
# use this script on a backup server, run as postgres,or whoever is db owner
# 
# N.B! dropdb will fail if db is accessed by other client(s) - stop apache beore running
#

use strict;
my $dow = (localtime)[6];
my $target = '/home/rails/backup/walkin'.$dow.'.gz';

print  "This is ", `uname -a`, `date`, " \n";
print "Dropping db 'walkin' \n";
`/usr/bin/dropdb --if-exists walkin -e`;
print "Creating db 'walkin'\n";
`/usr/bin/createdb walkin`;
print "Restoring DB walkin - full restore from latest backup\n";
`/bin/cat  $target | /bin/gunzip | /usr/bin/psql walkin`;
