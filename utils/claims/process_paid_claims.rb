# Reconcile claims with visits
# Requires range of dates eg: 2018-06-01 2018-07-01 (dates are visit dates, or svc_date in services)
# 
# Updates attributes : 
#   - visit.status to PAID 
#   - claim.visit_id : to visit id
#   - visit.export_file : sets to a claim.accounting_no if match found in lookup by ohip_num, date 
#   - visit.amount: sets to claim's paid amount
#   - visit.claim_id: sets to claim id of the  matching claim
#
# Look up claims for each visit in the date range by accounting_no (same as cabmd_ref)
# Mark visit as paid if the match is found
# if there's no match (claims submitted manually from cabmd) attempt to find claim by ohip_num and visit date
# if match found, update export_file field in visit with accounting_no from the claim, set visit amount to amount paid, 
# set visit claim id to id of matching claim
#
#
require_relative '../../config/environment'
#require 'date'
#require 'csv'

(sdate,edate) = ARGV
unless sdate
  puts "Usage: ruby proggy <start_date> [<end_date>]"
  exit
end
start_date = Date.parse(sdate) rescue 'Start date syntax error'
end_date = Date.parse(edate) rescue Date.today

puts "using #{start_date} as start date"
puts "using #{end_date} as end date"
puts "Will go through visits in given range, look for match in claims table and assign paid status,amount paid,claim id and visit id if match found"

ttl_amt_subm = ttl_amt_paid = 0
paid_count = not_paid_count = revised_count = 0
Visit.where("date(entry_ts) >= ? AND date(entry_ts) <= ?", start_date, end_date).each do |v| 
#   next unless v.status == BILLED
   next unless v.total_insured_services > 0

   cl = Claim.find_by(accounting_no: v.export_file)
   
   if cl.present?
      v.update_attributes(:status => PAID, :amount => cl.damt_paid, :claim_id => cl.id) 
      cl.update_attribute(:visit_id, v.id)
      ttl_amt_subm += cl.damt_subm
      ttl_amt_paid += cl.damt_paid
      if cl.amt_subm == cl.amt_paid 	   
#	   puts "Patient #{v.patient_id}, visit #{v.id}: submitted: #{v.total_insured_fees}; billed: #{cl.damt_subm} paid in full"
	   paid_count += 1
      else 
	   revised_count += 1
#	   puts "Payment revised for patient #{v.patient_id}, Visit #{v.id} #{v.entry_ts} : submitted: #{v.total_insured_fees};  billed: #{cl.damt_subm}, pd: #{cl.damt_paid}"
      end
   else
     pat = Patient.find(v.patient_id)
     claims = Claim.where(ohip_num: pat.ohip_num) 
     found = false
     claims.each do |c|
       if c.date == v.entry_ts.to_date 
         v.update_attributes(:status => PAID, :amount => c.damt_paid, :claim_id => c.id, :export_file => c.accounting_no) 
         c.update_attribute(:visit_id, v.id)
	 found = true
#	 puts "Patient #{v.patient_id}, visit #{v.id}: submitted: #{v.total_insured_fees.round(2)}; billed: #{c.damt_subm} paid in full"
	 break
       end
     end
     next if found
     not_paid_count += 1
     puts "No paid claim found for pat #{v.patient_id} (#{pat.pat_type}) HC#: #{pat.ohip_num} visit #{v.id} #{v.entry_ts} (#{v.bil_type_str}) by accounting_no or HC/visit date "
   end
end #visits

puts "#{paid_count} claims were paid in full; #{revised_count} claims were revised; #{not_paid_count} claims were not paid "
puts "Total amount submitted in this batch: #{ttl_amt_subm.round(2)}"
puts "Total amount paid in this batch: #{ttl_amt_paid.round(2)}"
