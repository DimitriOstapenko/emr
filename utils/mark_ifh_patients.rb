# Look through patients with type 'W' (Waiting for HC) and try to decide if they are IFH:
# If latest visit has procedure code then it's IFH patient. Assign pat_type 'I'
# Otherwise, if procedure is 3-rd party, or there's no visits, assign 'S' (Self pay, Cash) type to the patient
#  
#

require_relative '../config/environment'

patients = Patient.where(pat_type: 'W')

puts "will go through all 'W' patients and check if their visits have HCP proc. If yes, assign 'I', otherwise 'S' as pat_type"

pat_with_visits = pat_with_no_visits = ifh_pat = cash_pat = 0
patients.all.each do |pat|
  visits = pat.visits

  if visits.present?
	  pat_with_visits += 1
	  latest_visit = visits.first
	  if latest_visit.hcp_services?
             ifh_pat += 1
	     puts "Patient #{pat.id} has visits (#{visits.count}) and is IFH"
	  else
	     cash_pat += 1
	     puts "Patient #{pat.id} has visits (#{visits.count}) and is CASH"
	  end
  else
	  pat_with_no_visits += 1
	  cash_pat += 1
	  puts "Patient #{pat.id} has no visits - CASH"
  end
end


puts "With visits: #{pat_with_visits} ; without visits: #{pat_with_no_visits}; ifh: #{ifh_pat} cash: #{cash_pat}"

	




