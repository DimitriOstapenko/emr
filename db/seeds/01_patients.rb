#
# Seed patient table
#

# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'date'
require 'csv'

puts "About to import patients into DB table from CSV file. Validity checks for all but lname,dob,ohip_num (if ohip), ohip_ver (if ohip) should be off"

csv_text = File.read(Rails.root.join('lib', 'seeds', 'patdata.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

def valid_date?( str, format="%m/%d/%Y" )
  Date.strptime(str,format) rescue false
end

added = 0
#Patient.destroy_all
csv.each do |row|
#        puts row.to_hash

  patid = row['patid']
  ohip_num = row['ohip'].gsub(/\s/,'')
  next if Patient.exists?(ohip_num: ohip_num)

  areacode = row['acres'] || ''
  phone = areacode + row['rtele']
  
  altareacode = row['altac'] || ''
  alttel = row['alttel'] || ''
  alt_phone = altareacode + alttel
  alt_phone.gsub!(/\s/,'')

  sex = row['sex'].gsub(/\s/,'').upcase
  sex ='X' unless %w[M F X].include? sex

  lname = row['sname']
  next unless lname.match(/^[[:alpha:]]/)

  addr2 = row['address2'] || ''

  dob = Date.strptime(row['bdate'], '%m/%d/%Y') if valid_date?(row['bdate'])
  hin_expiry = Date.strptime(row['hin_expir'], '%m/%d/%Y') rescue nil #if valid_date?(row['hin_expir'])
  entry_date = Date.strptime(row['entry_date'], '%m/%d/%Y') rescue nil #if valid_date?(row['entry_date'])

  patient = Patient.new  lname: lname, #id: row['patid'],
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

  if patient.save(validate: false)
     puts "*** #{patient.id} : #{patient.lname} saved"
     added += 1
  else
     puts "Problem patient: #{patient.id}"
     puts patient.errors.full_messages
  end           

end

puts "#{Patient.count} patients now in patients table. Added #{added} patients."


