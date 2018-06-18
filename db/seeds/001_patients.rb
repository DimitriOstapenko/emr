#
# Insert only new patients for given day, new id is assigned
# expects date parameter in the format yyyy-mm-dd
#

# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'date'
require 'csv'

if ARGV[0].nil?
    puts "Usage: ./script.rb yyyy-mm-dd"
    exit
end

begin
target_date = ARGV[0].to_date
  rescue 
    puts 'Invalid date'
    exit
end

added = 0
puts "About to import new patients for date #{target_date} into DB from HS CSV file patdata.csv"

csv_text = File.read(Rails.root.join('lib', 'seeds', 'patdata.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

def valid_date?( str, format="%m/%d/%Y" )
  Date.strptime(str,format) rescue false
end

count = 0
csv.each do |row|
#  puts row.to_hash

  entry_date = Date.strptime(row['entry_date'], '%m/%d/%Y') rescue nil 
  next if entry_date != target_date
  patid = row['patid']
  ohip_num = row['ohip'].gsub(/\s/,'')

  count +=1
  puts "#{count} : #{patid} : #{ohip_num}"

  if (pat = Patient.exists?(ohip_num: ohip_num))
	  puts "patient #{row['sname']}, #{row['gname']} : #{row['ohip_num']} already in DB - skipping. Old/new: pat_id = #{pat.id} if pat_id == #{patid}"
	  next
  end

  next

  areacode = row['acres'] || ''
  phone = areacode + row['rtele']
  
  altareacode = row['altac'] || ''
  alttel = row['alttel'] || ''
  alt_phone = altareacode + alttel
  alt_phone.gsub!(/\s/,'')

  sex = row['sex'].gsub(/\s/,'').upcase
  sex ='X' unless %w[M F X].include? sex

  addr2 = row['address2'] || ''

  dob = Date.strptime(row['bdate'], '%m/%d/%Y') if valid_date?(row['bdate'])
  hin_expiry = Date.strptime(row['hin_expir'], '%m/%d/%Y') rescue nil #if valid_date?(row['hin_expir'])

  patient = Patient.new  lname: row['sname'],
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

  if patient.save(validate: true)
     puts "*** HS patid: #{patid} Our id: #{patient.id} : Last name: #{patient.lname} saved"
     added += 1
  else
     puts "Problem patient: #{row['sname']}, #{row['gname']} : #{ohip_num} "
     puts patient.errors.full_messages
  end           

end


puts "#{Patient.count} patients now in patients table. Added #{added} patients."


