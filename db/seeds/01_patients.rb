#
# Seed patient table
#

require 'date'
#require 'csv'
#csv_text = File.read('/Users/dmitri/rstuff/walkin/lib/seeds/patdata.csv')
#csv_text = File.read('/Users/dmitri/rstuff/walkin/lib/seeds/patdata.csv').force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv_text = File.read(Rails.root.join('lib', 'seeds', 'patdata.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' ).first(600)

def valid_date?( str, format="%m/%d/%Y" )
  Date.strptime(str,format) rescue false
end

Patient.destroy_all
csv.each do |row|
#        puts row.to_hash

  areacode = row['acres'] || ''
  phone = areacode + row['rtele']
  
  altareacode = row['altac'] || ''
  alttel = row['alttel'] || ''
  alt_phone = altareacode + alttel
  alt_phone.gsub!(/\s/,'')

  sex = row['sex'].gsub(/\s/,'').upcase
  sex ='X' unless %w[M F X].include? sex

  addr2 = row['address2'] || ''
  ohip_num = row['ohip'].gsub(/\s/,'')

  dob = Date.strptime(row['bdate'], '%m/%d/%Y') if valid_date?(row['bdate'])
  hin_expiry = Date.strptime(row['hin_expir'], '%m/%d/%Y') if valid_date?(row['hin_expiry'])
  entry_date = Date.strptime(row['entry_date'], '%m/%d/%Y') if valid_date?(['entry_date'])

  patient = Patient.new  id: row['patid'],
  			 lname: row['sname'],
                     	 fname: row['gname'],
			 mname: row['int'],
			 ohip_num: ohip_num,
			 ohip_ver: row['ver'],
			 hin_expiry: hin_expiry,
			 pat_type: row['pattype'],
                     	 dob: dob,
                     	 sex: sex,
                     	 phone: phone, 
                     	 addr: row['address1'] +' '+ addr2,
			 city: row['city'],
			 prov: row['prov'],
			 postal: row['pc'],
			 country: row['country'],
			 hin_prov: row['hin_prov'],
			 pharmacy: row['pharmacy'],
			 pharm_phone: row['phm_phone'],
			 alt_contact_phone:  altareacode + alttel,
			 email: row['email'],
			 family_dr: row['fam_dr'],
			 lastmod_by: row['mod_by'],
  			 entry_date: entry_date
#			 chart_file: 
#			 notes: 
#			 alt_contact_name:  
#			 mobile:
#			 last_visit_date:

  if patient.save
     puts "*** #{patient.id} : #{patient.lname} saved"
  else
     puts "Problem patient: #{patient.id}"
     puts patient.errors.full_messages
  end           

end

puts "#{Patient.count} patients added to patients table "

# Seed visits for first 10 patients alphabetically
#
patients = Patient.order(:lname).take(10)
50.times do
  notes = Faker::Lorem.sentence(5)
  diag_code = Faker::Number.number(6)
  proc_code = 'A09'
  patients.each { |patient| patient.visits.create!(notes: notes,
                                                 diag_code: diag_code,
                                                 proc_code: proc_code,
						 doc_id: 608
                                                )
                 }
end

