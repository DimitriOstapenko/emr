#
# Look for multiple records in patient table with the same lname, fname, dob;
# Consider them belonging to the same patient;
# Attempt to take one record with ohip_num defined and consider it master
# Cycle through visits for the patients and assign the same patient_id to all  
#
# N.B! this will croak on devel server with sqlite due to lack of regexp support
#
require_relative '../config/environment'

puts "Looking for patients with 2 cards by lname,fname, dob"
problem_patients_count = 0
merged_visits_count = 0

patients = Patient.select("lname,fname,dob").group("lname,fname,dob").having("count(*)>1").order("count(*) desc")

patients.each do | p |
        pat = Patient.where('lname=? AND fname=? AND dob=?', p.lname, p.fname, p.dob).where("ohip_num ~ '^\\d{10}$'")

# let's do patients with 2 good numbers:
	next unless pat.size == 2
	master_id = pat[0].id

	puts
	puts "#{p.lname} #{p.fname} #{p.dob}"
	puts "id1: #{master_id} : #{pat[0].ohip_num} : visits: #{pat[0].visits.ids}"
	puts "id2: #{pat[1].id} #{pat[1].ohip_num} : visits: #{pat[1].visits.ids}" if pat[1].present?

#	same_pats = Patient.where('lname=? AND fname=? AND dob=?', p.lname, p.fname, p.dob).where('id != ?', master_id)
#	same_pats.each do | sp |
		problem_patients_count += 1

#		sp.destroy if sp.visits.count < 1
#		puts "to merge: #{sp.id}"
#		puts "Visits to mod:  #{sp.visits.count}"
#		sp.visits.each do |v|
#		  puts "about to change pat_id : #{v.patient_id} to: #{master_id}" 
#		  v.update_attribute(:patient_id, master_id)
#		  merged_visits_count += 1
#		end
#	end
end

puts "#{problem_patients_count} problem patients; #{merged_visits_count} visits merged; Now run 12_update_last_visit_date and purge patients with no visits: delete from patients where last_visit_date is null and ohip_num is null;"

