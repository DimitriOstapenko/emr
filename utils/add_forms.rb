#
# Traverse forms tree and find all [type]_name.pdf files. Import name,filename,ftype,format into forms db table
# Ignore already imported files
#
# types: [WCB,LAB]
#
require_relative '../config/environment'
require 'find'

added = 0
dir = FORMS_PATH
abort "Forms directory does not exist." unless File.directory?(dir)

puts "About to add new forms from #{dir} to forms table"

Form.destroy_all
Find.find( dir ) do |path| 
	basename = File.basename(path)
	next unless match = basename.match(/^(WCB|LAB|MTO)\_?(\S+)\.(\w+)$/i)
	next if Form.exists?(filename: basename)

	added += 1

	(ftype,name,format) = match.captures
	
	form = Form.new name: name, filename: basename, ftype: FORM_TYPES[ftype.upcase.to_sym], format: FORM_FORMATS[format.upcase.to_sym]
	if form.save
          puts "Added form : #{basename}"
  	else
          puts "Already in: #{basename} - ignored"
#          puts form.errors.full_messages
  	end
end

puts "added #{added} files"
puts "Now #{Form.count} rows in forms table"


