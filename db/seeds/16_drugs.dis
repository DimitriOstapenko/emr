#
# Seed drugs table (insurance companies)
#
# Next lines allow to run it stand-alone
require_relative '../../config/environment'
require 'csv'

puts "About to seed drug table. Validity checks should be off"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'med_name.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

Drug.destroy_all 

csv.each do |row|
      	   drug = Drug.new name: row['drug'],
			   dnum: row['dnum'], 
  			   strength: row['strength'],                
			   dose: row['dose'],
			   freq: row['freq'], 
			   amount: row['amount'], 
			   status: row['status'], 
			   generic: row['generic'], 
			   igcodes: row['igcodes'], 
			   format: row['format'], 
			   route: row['route'],
			   dur_cnt: row['dur_cnt'], 
			   dur_unit: row['dur_unit'], 
			   refills: row['refills'], 
			   cost: row['cost'], 
			   lu_code: row['lu_code'], 
			   pharmacy: row['pharmacy'], 
			   aliases: row['aliases'], 
			   dtype: row['type'],
			   odb: row['odb'], 
			   filename: row['filename'], 
			   notes: row['notes'], 
			   instructions: row['instrinfo']

  if drug.save		         
	  puts "#{drug.id} #{drug.name} saved"
  else
	  puts 'Problem drug: ', drug.inspect
          puts drug.errors.full_messages
  end

end

puts " #{Drug.count} rows created in drug table"


