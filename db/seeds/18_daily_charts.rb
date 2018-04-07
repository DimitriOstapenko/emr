#
# Seed daily_charts table 
# Traverse charts/Daily tree and find all [date].pdf files. Import names into db table
#
# Next lines allow to run it stand-alone
require_relative '../../config/environment'
require 'find'

dir  = CHARTS_PATH.to_s + '/Daily'
puts "About to seed daily_charts table with files from #{dir}"

#DailyChart.destroy_all
#
Find.find( dir ) do |path| 
	basename = File.basename(path)
	next unless basename.match(/^\d{4}-\d{2}-\d{2}\.pdf$/)
	(date, ext) = basename.split('.') 
	reader = PDF::Reader.new( path )
	chart = DailyChart.new filename: basename, date: date, pages: reader.page_count
	if chart.save
          puts "#{basename} saved"
  	else
          puts 'Problem file: ', chart.inspect
          puts chart.errors.full_messages
  	end
end

puts " #{DailyChart.count} rows created in daily_charts table"


