#
# Seed providers table (insurance companies)
#
# Next lines allow to run it stand-alone
require_relative '../../config/environment'
require 'csv'

puts "About to seed provider table. Validity checks should be off"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'billto.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

Provider.destroy_all 

csv.each do |row|
  provider = Provider.new  id: row['bto_id'],
    			 name: row['name'],
		        addr1: row['address1'],
			addr2: row['address2'],
			 city: row['city'],
			 prov: row['prov'],
		      country: row['country'],
		       postal: row['post_code'],
		       phone1: row['phone1'],
		       phone2: row['phone2'],
		          fax: row['fax'],
     			email: row['email']

  if provider.save		         
	  puts "#{provider.id} #{provider.name} saved"
  else
	  puts 'Problem provider: ', provider.inspect
          puts provider.errors.full_messages
  end

end

puts " #{Provider.count} rows created in provider table"
