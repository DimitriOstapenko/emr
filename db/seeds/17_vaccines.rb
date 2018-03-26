#
# Seed vaccines table (insurance companies)
#
# Next lines allow to run it stand-alone
require_relative '../../config/environment'
require 'csv'

puts "About to seed vaccines table"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'vaccines.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

Vaccine.destroy_all 

csv.each do |row|
      	   vaccine = Vaccine.new name: row['name'],
	   		   target: row['target'],
			   dose: row['dose'], 
			   din: row['din']

  if vaccine.save		         
	  puts "#{vaccine.id} #{vaccine.name} saved"
  else
	  puts 'Problem vaccine: ', vaccine.inspect
          puts vaccine.errors.full_messages
  end

end

puts " #{Vaccine.count} rows created in vaccine table"


