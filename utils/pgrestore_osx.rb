# Drop local oms DB and restore it from latest backup from production
# - Run from cron on the same day as backup, but later
# - Run as owner of db 
# 
# N.B! dropdb will fail if db is accessed by other client(s) - stop server, debugger and db client before running! 
#
# This script is different on debian and OSX. Version below is for OSX

require_relative '../config/environment'
require 'date'

dow = Date.today.wday.to_s
target = '/Users/jimosta/emr/pgbackup/walkin'+dow+'.gz'
puts "This is restore.rb on #{Socket.gethostname} #{Date.today}"

puts "Dropping db 'walkin'"
system("/usr/local/bin/dropdb --if-exists walkin -e")
puts "Creating db 'walkin'"
system("/usr/local/bin/createdb walkin")
puts "Restoring oms db - full restore from latest backup #{target}"
system("/bin/cat #{target} | /usr/bin/gunzip | /usr/local/bin/psql walkin")
puts "done."

