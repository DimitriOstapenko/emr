#
# Traverse charts/Daily tree and find all [date].pdf files. Import names into db table
# Ignore already imported files
#
# Next lines allow to run it stand-alone
require_relative '../config/environment'
#require '/home/rails/walkin/config/environment'
require 'find'

dir  = CHARTS_PATH.to_s + '/Daily'
puts "About to update daily_charts table with files from #{dir}"

#DailyChart.destroy_all
#
Find.find( dir ) do |path| 
	basename = File.basename(path)
	next unless basename.match(/^\d{4}-\d{2}-\d{2}\.pdf$/)
	next if DailyChart.exists?(filename: basename)
	(date, ext) = basename.split('.') 
	reader = PDF::Reader.new( path )
	chart = DailyChart.new filename: basename, date: date, pages: reader.page_count
	if chart.save
          puts "Added chart : #{basename}"
  	else
          puts chart.errors.full_messages
  	end
end

puts "Now #{DailyChart.count} rows in daily_charts table"


