# download files from Dropbox using Dropbox-uploader script
#  - List files in dropbox root dir
#  - Get latest processed file date from daily_charts and use it to construct file names to look for 
#  - Download 15 charts, if present, to local Daily/[year] directory; Extract year from date; ignore already present files
#  - Move downloaded charts from root directory on dropbox to dropbox dir UploadedCharts/Daily
#
# Examples:
# ./dropbox_uploader.sh list UploadedCharts
# ./dropbox_uploader.sh upload test.pdf /
# ./dropbox_uploader.sh -s download test3.txt . # -s : do not overwrite
# ./dropbox_uploader.sh move /test.pdf /UploadedCharts/Daily/test.pdf
#
# /home/rails/Dropbox-Uploader/dropbox_uploader.sh download /2012-01-17.pdf /home/rails/emr/charts/Daily/2012/2012-01-17.pdf
#
# Script tested and works fine on development(OSX) and production(debian) boxes
#
require_relative '../config/environment'
SCRIPT = '/home/rails/Dropbox-Uploader/dropbox_uploader.sh'
DOWNLOAD_DIR = '/home/rails/emr/charts/Daily'

start_date = DailyChart.latest_chart_date.to_date + 1.day
end_date = start_date + 15.days
abort "Could not get latest chart date from DailyChart" unless start_date

puts "List of files in dropbox:"
system "#{SCRIPT} list /"

puts  "Will look for files in dropbox in the date range:  #{start_date}..#{end_date} "
count = 0
for date in start_date..end_date do
  filename = date.strftime("%Y-%m-%d.pdf")
#  puts  "system : #{SCRIPT} download /#{filename} #{DOWNLOAD_DIR}/#{date.year}/#{filename}"
  if system "#{SCRIPT} download /#{filename} #{DOWNLOAD_DIR}/#{date.year}/#{filename}"
    count += 1
#    puts "system : #{SCRIPT} move /#{filename} /UploadedCharts/Daily/#{filename}"
    system "#{SCRIPT} move /#{filename} /UploadedCharts/Daily/#{filename}"
  end
end

puts "#{count} files downloaded from dropbox to charts/Daily/#{start_date.year} directory"
