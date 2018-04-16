#
# Seed diagnoses table (icd8, 3 digit codes)
#
# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'date'
require 'csv'

# from http://www.wolfbane.com/icd/icd8.htm : make csv file:
#File.readlines(Rails.root.join('lib', 'seeds', 'diagfile_icd8.csv')).each do | line |
#  next unless line.match(/^\d{3}\s/)
#  puts line.chomp.split(/ /, 2).map{|e| '"' + e + '"'}.join(',')+ "\n"
#end

puts "About to seed diagnoses table. Validity checks for all but :code should be off"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'diagfile_icd8.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

Diagnosis.destroy_all 

csv.each do |row|
  diag = Diagnosis.new   code:  row['diag_code'],
		   	 descr: row['diag_desc'],
		         prob_type: '',
			 active: 't'
  if diag.save		         
	  puts "#{diag.id} #{diag.code} saved"
  else
	  puts 'Problem code: ', diag.inspect
          puts diag.errors.full_messages
  end

end

puts " #{Diagnosis.count} rows created in diagnoses table"
