# Take all lname,fname.pdf files and mport names, and number of pages into db charts table
#   - Ignore non-pdf files
#   - Ignore already imported files
#   - Find corresponding patient using lname, fname
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
	if !basename.match(/^\S+\.pdf$/)
 	  puts "File #{basename} is ignored - not a pdf file" 
	  next
	end

	next if Chart.exists?(filename: basename) 

	reader = PDF::Reader.new( path )
	(lname,fname) = basename.match(/(\S+)\,([a-z]+)/i)[1,2]
	lname.gsub!('_',' ')
	patient = Patient.where("lname like ? AND fname like ?", "#{lname}%", "#{fname}%") 
	patient_id = patient[0].id rescue nil
	
	unless patient_id
	  puts "Patient #{lname}, #{fname} was not found in DB - chart ignored" 
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


