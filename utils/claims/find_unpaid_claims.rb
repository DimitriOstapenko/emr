# Go through HCP visits in given date range (last 2 months by default) and find visits without:
#  - CabmdRef in visits.export_file field 
#  - corresponding MOH claim.accounting_no in claims
#
#
require_relative '../../config/environment'

@sdate = ARGV[0].to_date rescue Date.today - 2.months
@edate = Date.today

puts "using #{@sdate} as start date"
puts "Will go through visits in given range, look for missing cabmd_refs and missing match in claims table. Issue alert in both cases " 

def found_by_hc_and_date?(visit)
     pat = Patient.find(visit.patient_id)
     claims = Claim.where(ohip_num: pat.ohip_num) 
     claims.each do |c|
       return true if c.date == visit.entry_ts.to_date 
     end
end

good_claims_count = noacc_ref_count = no_claim_count = 0
Visit.where(entry_ts: (@sdate..@edate)).where(status: (4..5)).each do |v| 

# This will cover all HCP containing visits and will exclude all CSH, INV, IFH and PRV claims	
   next unless v.total_insured_services > 0

   if v.export_file.present? && v.export_file.match(/^\w{8}/)
      if Claim.exists?(accounting_no: v.export_file)
	 good_claims_count += 1
      else
	 no_claim_count += 1
         puts "Unpaid claim: No paid claim present for  #{v.patient_id} (#{pat.pat_type}) HC#: #{pat.ohip_num} visit #{v.id} #{v.entry_ts} (#{v.bil_type_str}); "
      end
   elsif found_by_hc_and_date?(v)
       good_claims_count += 1
       puts "Visit #{v.id} acc_ref: (#{v.export_file}) does not match paid claim acc_ref. But claim was paid"
   else 	     
     no_acc_ref_count += 1
     puts "Unsubmitted: No Accounting ref present for  #{v.patient_id} (#{pat.pat_type}) HC#: #{pat.ohip_num} visit #{v.id} #{v.entry_ts} (#{v.bil_type_str}); "
   end
end 

puts "Good claims: #{good_claims_count}; Unsubmitted claims: #{noacc_ref_count}; Submitted but unpaid claims: #{no_claim_count}"
