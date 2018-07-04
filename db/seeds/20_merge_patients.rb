#
# Look for multiple records in patient table with the same lname, fname, dob;
# Consider them belonging to the same patient;
# Attempt to take one record with ohip_num defined and consider it master
# Cycle through visits for the patients and assign the same patient_id to all  
#
# N.B! this will croak on devel server with sqlite due to lack of regexp support
#
require_relative '../../config/environment'

puts "About to merge patients: all visits will be moved to one patient record with ohip_num defined"
merged_visits_count = 0

patients = Patient.select("lname,fname,dob").group("lname,fname,dob").having("count(*)>1").order("count(*) desc")

patients.each do | p |
        pat = Patient.where('lname=? AND fname=? AND dob=?', p.lname, p.fname, p.dob).where("ohip_num ~ '^\\d{10}$'")

# let's do patients with 1 good number:
	next unless pat.size == 1
	master_id = pat[0].id

	print "#{master_id} : #{p.lname} #{p.fname} #{p.dob} : #{pat.size} record with good ohip_num : "
	print pat[0].ohip_num if pat[0].present?
	print ':'
	print pat[1].ohip_num if pat[1].present?
	puts 

	same_pats = Patient.where('lname=? AND fname=? AND dob=?', p.lname, p.fname, p.dob).where('id != ?', master_id)
	same_pats.each do | sp |
		puts "to merge: #{sp.id}"
		puts "Visits to mod:  #{sp.visits.count}"
		sp.visits.each do |v|
		  puts "about to change pat_id : #{v.patient_id} to: #{master_id}" 
		 # v.update_attribute(:patient_id, master_id)
		  merged_visits_count += 1
		end
	end
end

puts "#{merged_visits_count} visits merged; Now purge patients with no visits"

