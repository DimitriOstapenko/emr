#
# Find billings for each visit and assign billed procedures to corresponding fields in visits
#
#
require_relative '../../config/environment'

puts "About to set proc_code,units and fee in visits table from billings table"

updated = 0

Visit.where("entry_ts >'2011-01-01'").each do |v|
#Visit.all.each do |v|

  billings = Billing.where(visit_id: v.id)
  if billings.present? && billings.first.pat_id != v.patient_id
	  puts "billing patient id is defferent from visit patient id: #{billings.first.pat_id} : #{v.patient_id}"
	  next
  end

#  puts "doing #{v.id}"
  v.status = PAID
  v.export_file = billings.first.submit_file rescue ''
  v.diag_code = billings.first.diag_code rescue nil
  v.amount = billings.first.amt_paid rescue nil

  billings.each_with_index do | b, index |

    case index
    when 0
            v.proc_code = b.proc_code
            v.units = b.proc_units
            v.fee = b.fee
	    v.bil_type = BILLING_TYPES[b.btype.upcase.to_sym]
    when 1
            v.proc_code2 = b.proc_code
            v.units2 = b.proc_units
            v.fee2 = b.fee
	    v.bil_type2 = BILLING_TYPES[b.btype.upcase.to_sym]
    when 2
            v.proc_code3 = b.proc_code
            v.units3 = b.proc_units
            v.fee3 = b.fee
	    v.bil_type3 = BILLING_TYPES[b.btype.upcase.to_sym]
    when 3
            v.proc_code4 = b.proc_code
            v.units4 = b.proc_units
            v.fee4 = b.fee
	    v.bil_type4 = BILLING_TYPES[b.btype.upcase.to_sym]
    else
            puts "visit #{v.id} index #{index} is outside of [0..3]"
    end

    if v.save(validate: false)
       puts "*** #{v.id} : patient #{v.patient_id} : #{v.entry_ts} updated"
       updated += 1
    else
       puts "Problem visit: #{v.id}"
       puts v.errors.full_messages
    end
  end

end

puts "Updated #{updated} visits."

