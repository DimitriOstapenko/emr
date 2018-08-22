# Parse CSV Provided Servces/Entered Report from Cab.md for any period (monthly is recommended) and compare with what was submitted by us 
# Provided services includes all claims successfully submitted to OHIP
# We ignore days with less than 10 services - those are from previous pay cicles
#
# CSV Header line:
# ref,hc,vc,prov,patname,dob,sdate,pcode,units,sub_fee,errcode
# ref,patname,hc,vc,loc,master,sdate,code,units,prov,fee,entdate,bmethod,dob,err_code
#
require_relative '../config/environment'
require 'csv'
require 'date'

#filename = 'entered.csv'
filename = 'eo_entered_aug_2018.csv'

csv_text = File.read(Rails.root.join('export', filename)).encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

puts "Scanning CAB.md exported csv report #{filename.inspect}" 

pat_count = visit_count = 0
# Find patient/visit in db, insert new if not found
csv.each do |row|
	hc = row['hc']
	next unless hc
	visit_date = Date.strptime(row['sdate'], '%m/%d/%Y') rescue nil
	next unless visit_date.present?

	pat = Patient.find_by(ohip_num: hc)
	if pat.present?
           visit = pat.visits.where('date(entry_ts)=?', visit_date)
           puts "Patient exists: #{pat.id}; visit for #{visit_date}"
	   if visit.present?
	     puts " -- found. ignoring."
	   else
             puts " -- not found. Will insert"
	     proc_code = row['code']
	     units = row['units']

	     visit_count += 1
	   end
	else
	  puts "Patient with hc #{hc} does not exist in db. Creating."
	  (lname,fname) = row['patname'].split(/\s*,\s*/)
	  dob = Date.strptime(row['dob'], '%m/%d/%Y') rescue nil
	  hin_prov = row['prov']
	  vc = row['vc']
	  pat = Patient.new(lname: lname, fname: fname, ohip_num: hc, ohip_ver: vc, hin_prov: hin_prov, dob: dob, pat_type: HCP_PATIENT, sex: 'X')  # Sex unknown!
	  if pat.save(validate: false)
             puts "patient created"
	     pat_count += 1
	  else
	     puts "could not save patient"
	  end
	end
end

puts "Created #{pat_count} patients, #{visit_count} visits"

