#
# Parse monthly remittance advice (RA) file from MOH, get totals for each doctor and each day 
#
# ex: PG0078.398
#
require_relative '../config/environment'
require 'date'
require 'csv'

(sdate,edate) = ARGV
unless sdate
  puts "Usage: ruby proggy <start_date> [<end_date>]"
  exit
end
start_date = Date.parse(sdate) rescue 'Start date syntax error'
end_date = Date.parse(edate) rescue Date.today

puts "using #{start_date} as start date"
puts "using #{end_date} as end date"
puts "Will go through *billed* visits in given range, look for match in claims table and assign paid status if match found"

ttl_amt_subm = ttl_amt_paid = 0
paid_count = not_paid_count = revised_count = 0
Visit.where("date(entry_ts) >= ? AND date(entry_ts) <= ?", start_date, end_date).each do |v| 
   next unless v.status == BILLED
   next unless v.hcp_services?

   cl = Claim.find_by(accounting_no: v.export_file)
   
   if cl.present?
      v.update_attribute(:status, PAID) 
      if cl.amt_subm == cl.amt_paid 	   
#	   puts "Patient #{v.patient_id}, visit #{v.id}: submitted: #{v.total_insured_fees}; billed: #{cl.damt_subm} paid in full"
	   ttl_amt_paid += cl.damt_paid
	   ttl_amt_subm += cl.damt_subm
	   paid_count += 1
      else 
	   revised_count += 1
	   ttl_amt_paid += cl.damt_paid
	   ttl_amt_subm += cl.damt_subm
	   puts "Payment revised for patient #{v.patient_id}, Visit #{v.id} #{v.entry_ts} : submitted: #{v.total_insured_fees};  billed: #{cl.damt_subm}, pd: #{cl.damt_paid}"
      end
   else
	   pat = Patient.find(v.patient_id)
	   claims = Claim.where(ohip_num: pat.ohip_num) 
	   found = false
	   claims.each do |c|
	     if c.date == v.entry_ts.to_date 
		v.update_attribute(:export_file, c.accounting_no) 
		v.update_attribute(:status, PAID) 
		found = true
		puts "Patient #{v.patient_id}, visit #{v.id}: submitted: #{v.total_insured_fees.round(2)}; billed: #{c.damt_subm} paid in full"
		break
	     end
	   end
	   next if found
	   not_paid_count += 1
	   puts "No paid claim found for pat #{v.patient_id} #{pat.ohip_num} visit #{v.id} #{v.entry_ts} by accounting_no or HC/visit date "
   end
end

puts "#{paid_count} claims were paid in full; #{revised_count} claims were revised; #{not_paid_count} claims were not paid "
puts "Total amount submitted in this batch: #{ttl_amt_subm.round(2)}"
puts "Total amount paid in this batch: #{ttl_amt_paid.round(2)}"
