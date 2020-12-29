# Traverse charts/Daily tree and find all [date].pdf files. Import names into db table
# Ignore already imported files
#
# Next lines allow to run it stand-alone
require_relative '../config/environment'
require 'find'
require 'fileutils'

dir  = CHARTS_PATH.join('Daily')
dir = File.realdirpath( dir ) if File.symlink?( dir )

puts "About to update daily_charts table with files from #{dir}"
        
charts_count = 0
Find.find( dir ) do |path| 
	basename = File.basename(path)
        puts basename
	next unless basename.match(/^\d{4}-\d{2}-\d{2}\.pdf$/)
	next if DailyChart.exists?(filename: basename)
	(date, ext) = basename.split('.') 
	reader = PDF::Reader.new( path )
	chart = DailyChart.new filename: basename, date: date, pages: reader.page_count
	if chart.save
          puts "Added chart : #{basename}"
	  charts_count += 1
  	else
          puts chart.errors.full_messages
  	end
end

# Need read permission to view files
#FileUtils.chmod "go+r", Dir.glob(File.join(CHARTS_PATH,'*','*','*.pdf')) 

puts "Added #{charts_count} charts to charts table"
puts "Now #{DailyChart.count} rows in daily_charts table"

