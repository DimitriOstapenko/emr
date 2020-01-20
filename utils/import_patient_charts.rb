# Take all [pat_id].pdf files and import into charts 
#   - Ignore non-pdf files and files with other than digits in name
#   - Ignore already imported files
#   - Find corresponding patient using file name as patient.id 
#   - Ignore files with no corresponding patient
#
require_relative '../config/environment'
#require 'find'
#require 'fileutils'

dir  = CHARTS_PATH
puts "About to update charts table with files from #{dir}"

#Chart.destroy_all

charts_count = 0
Dir.glob( "#{dir}/*.pdf" ) do |path| 
	basename = File.basename(path)
        next unless basename =~ /^\d+\.pdf$/
	next if File.exists?(path) 

	reader = PDF::Reader.new( path )
        (name,ext) = split('.')
        patient_id = name.to_i rescue nil
	
	unless patient_id
	  puts "Patient with id #{patient_id} was not found in DB - chart ignored" 
	  next
	end

	chart = Chart.new(filename: basename, pages: reader.page_count, patient_id: patient_id)
	if chart.save
	  puts "Added chart : #{basename} (#{chart.id})"
	  charts_count += 1 
  	else
          puts chart.errors.full_messages
  	end
end

puts "added #{charts_count} charts"
puts "Now #{Chart.count} rows in charts table"


