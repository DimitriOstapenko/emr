# Parse CSV Entered Report from Cab.md in export directory for any period (monthly is recommended) and compare with what was submitted by us 
# Provided services includes all claims successfully submitted to OHIP
# We ignore days with less than 10 services - those are from previous pay cycles
#
# CSV Header line required columns: (order doesn't matter, only used field names do)
# ref,hc,vc,prov,patname,dob,sdate,pcode,units
#
# Restrictions: 
#   1. CAB files don't have doctor id. We use same id for all. Then, doctors will have to be assigned manually
#      alternatively, use individual files and supply doctor's provider_no as a second parameter
#   2. There's no time of visit in the file. We will assign times consecutively starting at 9am with 10 min increments
#   3. There's no diagnostic code in the file. This will have to be assign manually as well
#   4. Patient's sex is also missing in the file. We will use 'X'(undefined) for all new patients, hopefully there's very few
#
require_relative '../config/environment'
require 'csv'
require 'date'

(filename, provider_no, datetsr) = ARGV

abort "Usage: proggy <file_base_name>  [<provider_no>] [<date>]" unless filename
provider_no ||= '015539' # EO
date = Date.strptime(datestr, '%Y-%m-%d') rescue nil

$doc = Doctor.find_by(provider_no: provider_no)
$entry_ts = Time.now

puts "Scanning CAB.md exported csv report #{filename.inspect}, no provider_no given - assuming #{provider_no} by default" 
puts "Using date #{date.to_s}" if date.present? 

csv_text = File.read(Rails.root.join('export', filename)).encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   

# Let's check if header is good to go
required_keys = %w(ref hc vc prov patname dob sdate pcode units)
rowhash = csv.first.to_h rescue {}
ind = required_keys.index {|key| !rowhash.has_key?(key)}
abort "required header field #{required_keys[ind]} is missing/has different name" if ind

# Header is good, go through all visits in the file, ignore the rest if the date is given
def patient_created?(row)
  (lname,fname) = row['patname'].split(/\s*,\s*/)
  hc = row['hc']
  vc = row['vc'] rescue ''
  hin_prov = row['prov']
  pat_type = hin_prov == 'ON' ? HCP_PATIENT : RMB_PATIENT
  dob = Date.strptime(row['dob'], '%m/%d/%Y') rescue nil
  pat = Patient.new(lname: lname, 
		    fname: fname, 
	    	    ohip_num: hc, 
	    	    ohip_ver: vc, 
	    	    hin_prov: hin_prov, 
	    	    dob: dob, 
	    	    pat_type: pat_type,
	    	    sex: 'X')
  pat.save(validate: false)
end

def visit_created?(pat,row)
  pcode = row['pcode']
  units = row['units']
  billing_ref = row['ref']
  visit = Visit.where("patient_id=? AND date(entry_ts)=?", pat.id, $entry_ts.to_date).first
  if visit.present?
     case
       when visit.proc_code2.blank? 
	       visit.update_attributes(:proc_code2=> pcode, :bil_type2 => HCP_BILLING, :units2=> units)
       when visit.proc_code3.blank? 
	       visit.update_attributes(:proc_code3=> pcode, :bil_type3 => HCP_BILLING, :units3=> units)
       when visit.proc_code4.blank? 
	       visit.update_attributes(:proc_code4=> pcode, :bil_type4 => HCP_BILLING, :units4=> units) 
       end
  else	  
    $entry_ts += 10.minutes
    new_visit = pat.visits.create( entry_ts: $entry_ts,
   		      	     doc_id: $doc.id, 
			     proc_code: pcode, 
			     units: units,
			     bil_type: HCP_BILLING,
			     diag_code: '460',           #!!!!!  Fake 
			     billing_ref: billing_ref)
    new_visit.save(validate: false)            # no diagnosis - don't validate
  end
end

pat_count = svc_count = 0
visit_date = Date.today
# Find patient/visit in db, insert new if not found
csv.each do |row|
	hc = row['hc']
	next unless hc

	prev_date = visit_date
	visit_date = Date.strptime(row['sdate'], '%m/%d/%Y') rescue nil
	next unless visit_date.present?
	next if date.present? && visit_date != date

	pat = Patient.find_by(ohip_num: hc)
	if pat.present?
           puts "Patient exists: #{pat.id}; looking for visit of #{visit_date}"
	   $entry_ts = visit_date + 9.hours if visit_date != prev_date
	   visit = pat.visits.where('date(entry_ts)=?', visit_date).first
	   next if visit.present? && visit.has_proc?(row['pcode'])
           puts " -- not found. Will import"
	   if visit_created?(pat,row)
	      puts "New visit saved"
	      svc_count += 1
	   else
	      puts "Could not save visit"
	   end
	else
	  puts "Patient with hc #{hc} does not exist in db. Creating."
	  if patient_created?(row)
             puts "patient created"
	     pat_count += 1
	  else 
	     puts "could not create new patient"
	  end
	end
end

puts "Created #{pat_count} patients, #{svc_count} services"

