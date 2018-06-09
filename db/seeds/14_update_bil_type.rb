#
# Update bil_type in visits table from legacy billing
# Each procedure in visit will be assigned corresponding billing type
# 

require_relative '../../config/environment'

puts "About to update bil_type in visits table from billings table"

count  = 0

Visit.where("entry_ts > '2018-06-04'").each do |v|
#Visit.all.each do |v|

  bills = Billing.where(visit_id: v.id)

  if bills.nil?
    puts  "Visit #{v.id} doesn't have billing"
  else
    bills.each do |b|
            if v.proc_code.eql? b.proc_code
               v.bil_type = BILLING_TYPES[b.btype.to_sym]
               count += 1
            elsif v.proc_code2.eql? b.proc_code
               v.bil_type2 = BILLING_TYPES[b.btype.to_sym]
               count += 1
            elsif v.proc_code3.eql? b.proc_code
               v.bil_type3 = BILLING_TYPES[b.btype.to_sym]
               count += 1
            elsif v.proc_code4.eql? b.proc_code
               v.bil_type4 = BILLING_TYPES[b.btype.to_sym]
               count += 1
            end
            v.save()
            puts "Visit #{v.id} updated. Billing type: #{v.bil_type}"
    end
  end

end

puts "In visits:  #{count} procedures were assigned billing types from legacy billing table"

