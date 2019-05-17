# Go through patients, get current patient type and set visit.pat_type to it 
#
#  Some visits for patients who were IFH/CASH/RMB before will be wrong, but most will be right

require_relative '../config/environment'

puts "will go through all patients and set their visit.pat_type to patient's pat_type" 

Patient.all.each do |pat|
  pat.visits.each do |v| 
    puts "Updating visits for patient #{pat.id}" 
    v.update_attribute(:pat_type,pat.pat_type)
    if pat.pat_type == IFH_PATIENT
       v.update_attribute(:hin_num, pat.ifh_number)
    elsif pat.pat_type == CASH_PATIENT
    else
       v.update_attribute(:hin_num, pat.ohip_num)
    end
  end
end


	




