# Go through HCP visits in given date range (last 6 months by default) and find visits without:
#  - billing reference in visits.billing_ref field 
#  - corresponding MOH claim.accounting_no in claims
#
# Only insured visits are taken into account
#
# Update status to paid and claim.visit_id to visit.id if claim found but no acc_ref present (manual entry)
# Update attributes : 
#   - visit.status to PAID 
#   - claim.visit_id : to visit id (paid, unpaid and duplicate claims)
#   - visit.billing_ref : sets to a claim.accounting_no if match found in lookup by ohip_num and date 
#   - visit.amount: sets to claim's paid amount from good claim (paid_amt > 0)
#   - visit.claim_id: sets to claim id of the matching claim
#  
#  @cutoff_date is latest service date found in services table; This date is used as end date of the range and also as a trigger for visit resubmission
#  So, if visit was not found in paid claims and visit date is older than 1 month before @cutoff_date, then visit is marked for resubmission.
#
# N.B End date is the date of latest successful claim in claims table
#
require_relative '../../config/environment'

@sdate = ARGV[0].to_date rescue Date.today - 6.months
@edate = ARGV[1].to_date rescue nil
# Latest service date from RA file, if not present
@cutoff_date = Service.order(svc_date: :desc).limit(1).pluck(:svc_date).first rescue Date.today
@edate ||= @cutoff_date 

puts "Scanning claims in #{@sdate}..#{@edate} date range"
puts "..Looking for missing acc_refs and no match in claims table. Will issue alert in both cases " 

def __found_by_hc_and_date?(pat,visit)
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

def found_by_hc_and_date?(pat,visit)
  paid_claim = Claim.joins(:services).where(ohip_num: pat.ohip_num)
                    .where('services.svc_date': visit.entry_ts.to_date)
                    .group('services.svc_date,claims.id').having('SUM(amt_paid)>0')[0] rescue nil
  if paid_claim
    visit.update_attributes(:status => PAID, :amount => paid_claim.damt_paid, :claim_id => paid_claim.id, :billing_ref => paid_claim.accounting_no)
    paid_claim.update_attribute(:visit_id, visit.id)
    puts "Found by HC/Date : updated: pat: #{pat.id} visit: #{visit.id} date: #{paid_claim.date}"
    return true
  else
    return false
  end
end

# Scan all visits in date range
good_claims_count = no_acc_ref_count = no_claim_count = 0
Visit.where(entry_ts: (@sdate..@edate)).where(status: (BILLED..PAID)).each do |v| 

# This will cover all HCP containing visits and will exclude all CSH, INV, IFH and PRV claims	
   next unless v.total_insured_services > 0
   pat = Patient.find(v.patient_id)

# We are only interested in insured patients   
   next unless [HCP_PATIENT,RMB_PATIENT,WCB_PATIENT].include?(pat.pat_type)

   if v.billing_ref.present? #&& v.billing_ref.match(/^\w{8}/)
      claims = Claim.where(accounting_no: v.billing_ref)
      if claims.any?
         claims.each do |cl| 
           if cl.amt_paid > 0
             v.update_attributes(:status => PAID, :amount => cl.damt_paid, :claim_id => cl.id) if cl.amt_paid > 0
	     good_claims_count += 1
           end
           cl.update_attribute(:visit_id, v.id)
         end
      elsif found_by_hc_and_date?(pat,v) 
         good_claims_count += 1
      else
	 no_claim_count += 1
	 puts "Unpaid: No paid claim found for pat #{v.patient_id} HC# #{pat.ohip_num} visit #{v.id} of #{v.entry_ts} (#{v.bil_type_str})"
         if (v.entry_ts.to_date < @cutoff_date - 1.month) && (v.status < PAID)
            v.update_attributes(:status => READY)  # bug in RMB visits claim import - ignoring for now
            puts '** Older than 1 month, so this visit marked for resubmission'
         end
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
