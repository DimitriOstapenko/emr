# download files from Dropbox using Dropbox-uploader script
# use 2 dates to call transfer script for each date in the range starting with sdate
#
require 'date'

(sdate,edate) = Date.parse(ARGV[0]), Date.parse(ARGV[1]) rescue nil
abort "Usage: ruby proggy [start date] [end date]" unless (sdate && edate)
abort "Error: start date is after end date" if sdate > edate

puts "good range : #{sdate} - #{edate}"

count = 0
for date in sdate..edate do
    count += 1 if system "./dropbox_uploader.sh download #{date}.pdf ../emr/charts/Daily/2008/."
end

puts "#{count} files downloaded from dropbox to 2008 directory"
