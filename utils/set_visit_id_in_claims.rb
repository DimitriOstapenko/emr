# Go through all claims in claims table and set visit_id field, if not set, from visits table
# Lookup by HC#, visit date
# Update attributes:
#   - claim.visit_id to matched visit id
#   - visit.export_file to claim.accounting_no
#


require_relative '../config/environment'
require 'date'
require 'csv'

count = 0
Claim.all.each do |cl|
  next if cl.visit_id.present?
  next unless cl.ohip_num.present?
  
  pat = Patient.find_by(ohip_num: cl.ohip_num)  
  next unless pat.present?

  visits = Visit.where("patient_id =? AND date(entry_ts)=?", pat.id, cl.date)
  visit = [] 
  visits.each do |v|
    visit=v if v.total_insured_services > 0
  end

  next unless visit.present?
  puts "#{cl.id} : pat: #{pat.id} : vis: #{visit.id} date: #{cl.date} " 
  cl.update_attribute(:visit_id, visit.id)
  visit.update_attribute(:export_file, cl.accounting_no)
  count +=1

end

puts "Assigned visit_id to #{count} claims"
