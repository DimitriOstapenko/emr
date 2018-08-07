# Go through HCP visits in given date range (last 2 months by default) and find visits without:
#  - CabmdRef in visits.billing_ref field 
#  - corresponding MOH claim.accounting_no in claims
#
# Updates status to paid and claim.visit_id to visit.id if claim found but no acc_ref present (manual entry)
# Updates attributes : 
#   - visit.status to PAID 
#   - claim.visit_id : to visit id
#   - visit.billing_ref : sets to a claim.accounting_no if match found in lookup by ohip_num, date 
#   - visit.amount: sets to claim's paid amount
#   - visit.claim_id: sets to claim id of the  matching claim
#
# N.B End date is the date of latest successful claim in claims table
#
require_relative '../../config/environment'

@sdate = ARGV[0].to_date rescue Date.today - 2.months
@edate = Service.order(svc_date: :desc).limit(1).pluck(:svc_date).first rescue Date.today
@edate = @edate.next_day

puts "Scanning claims in #{@sdate}..#{@edate} date range"
puts "..Looking for missing acc_refs and no match in claims table. Will issue alert in both cases " 

def found_by_hc_and_date?(pat,visit)
     claims = Claim.where(ohip_num: pat.ohip_num) 
     claims.each do |c|
       if c.date == visit.entry_ts.to_date 
         visit.update_attributes(:status => PAID, :amount => c.damt_paid, :claim_id => c.id, :billing_ref => c.accounting_no)
         c.update_attribute(:visit_id, visit.id)
	 puts "Found by HC/Date : updated: pat: #{pat.id} visit: #{visit.id} date: #{c.date}"
	 return true
       end
     end
     return false
end

good_claims_count = no_acc_ref_count = no_claim_count = 0
Visit.where(entry_ts: (@sdate..@edate)).where(status: (BILLED..PAID)).each do |v| 

# This will cover all HCP containing visits and will exclude all CSH, INV, IFH and PRV claims	
   next unless v.total_insured_services > 0
   pat = Patient.find(v.patient_id)
   next unless [HCP_PATIENT,RMB_PATIENT,WCB_PATIENT].include?(pat.pat_type)

   if v.billing_ref.present? && v.billing_ref.match(/^\w{8}/)
      if cl = Claim.find_by(accounting_no: v.billing_ref)
         v.update_attributes(:status => PAID, :amount => cl.damt_paid, :claim_id => cl.id) 
         cl.update_attribute(:visit_id, v.id)
	 good_claims_count += 1
      elsif found_by_hc_and_date?(pat,v) 
         good_claims_count += 1
      else
	 no_claim_count += 1
         puts "Unpaid: No paid claim present for pat #{v.patient_id} visit #{v.id} of #{v.entry_ts} (#{v.bil_type_str}); "
      end
   elsif found_by_hc_and_date?(pat,v)
       good_claims_count += 1
       puts "Pat #{v.patient_id}, Visit #{v.id} acc_ref: (#{v.billing_ref}) not found in claims table, but claim for this HC/date was paid by MOH. Fixed attributes."
   else 	     
     no_acc_ref_count += 1
     puts "Unsubmitted?: No valid Accounting ref present for pat #{v.patient_id} visit #{v.id} #{v.entry_ts} (#{v.bil_type_str}); Possibly unsubmitted."
   end
end 

puts "Good claims: #{good_claims_count}; Unsubmitted claims: #{no_acc_ref_count}; Submitted but unpaid claims: #{no_claim_count}"
