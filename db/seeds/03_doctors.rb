#
# Seed doctors table from CSV file
#
# Next 3 lines allow to run it in stand-alone mode
require_relative '../../config/environment'
require 'date'
require 'csv'

puts "About to seed doctors table. Validity checks for all but lname, billing_num should be off"

csv_text = File.read(Rails.root.join('lib', 'seeds', 'doctors.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

#Doctor.destroy_all

added = 0
csv.each do |row|
#	 puts row.to_hash
  code = row['docid']
  next if Doctor.exists?(doc_code: code)
  name = row['name']	
  name.gsub /DR\S?/, ''
  names = name.split(%r{,\s*})
  next unless names[0]
  names[1] = '' if names[1].nil?

  doc  = Doctor.new  lname:  names[0],
     		     fname:  names[1], 
		     cpso_num: row['cpso'],
     		     billing_num: '0',
		     service: row['scode'], 
		     ph_type: row['type'],
		     district: row['district'],
		     bills: row['bills'],
		     address: row['address1'],
		     city: row['city'],
		     prov: row['prov'],
		     postal: row['pc'],
		     phone: row['acode']+row['tele'],
		     mobile: row['altac'] + row['alttel'],
		     licence_no: row['licence_no'],
		     note: '',
		     office: row['office'],
		     provider_no: row['provider'],
		     group_no: row['group_no'],
		     specialty: row['specialty'],
		     email: row['email'],
		     doc_code: code

  if doc.save
     puts "#{doc.id} : #{doc.lname} saved"
     added += 1
  else
     puts 'Problem doc: '+ doc.lname
     puts doc.errors.full_messages
  end

end

puts "Additional #{added} rows created. #{Doctor.count} now in doctors table"

#
#50.times do |n|
#        llname  = Faker::Name.last_name
#        fname  = Faker::Name.first_name
#        cpso = Faker::Number.number(5)
#        billing = Faker::Number.number(6)
#        lic = Faker::Number.number(8)
#        group_no = Faker::Number.number(4)
#        addr = Faker::Address.street_address
#        city = Faker::Address.city
#        phone  = Faker::PhoneNumber.phone_number
#        Doctor.create!(lname: llname,
#                       fname: fname,
#                       cpso_num: cpso,
#                       billing_num: billing,
#                       service: 'GENP',
#                       ph_type: 'GP',
#                       district: 'G',
#                       bills: true,
#                       address: addr,
#                       city: city,
#                       prov: 'ON',
#                       postal: 'L9G1G1',
#                       phone: phone,
#                       mobile: phone,
#                       licence_no: lic.to_s,
#                       note: 'empty',
#                       office: addr,
#                       provider_no: billing,
#                       group_no: group_no.to_s,
#                       specialty: '00',
#                       email: 'em@email.com'
#                      )
#end

