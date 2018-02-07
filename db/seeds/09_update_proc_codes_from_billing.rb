#
# Find billings for each visit and assign procedures to corresponding fields in visits
#
#


require_relative '../../config/environment'

Visit.first(100) do |v|
  puts "visit : #{v.id}"
  billings = Billing.where(visit_id: v.id)
  billings.each_with_index do | b, index |
#   puts "proc: #{b.proc_code}"
    case index
    when 0 
	    v.proc_code = b.proc_code
	    v.units = b.proc_units
	    v.fee = b.fee
    when 1
	    v.proc_code2 = b.proc_code
	    v.units2 = b.proc_units
	    v.fee2 = b.fee
    when 2
	    v.proc_code3 = b.proc_code
	    v.units3 = b.proc_units
	    v.fee3 = b.fee
    when 3
	    v.proc_code4 = b.proc_code
	    v.units4 = b.proc_units
	    v.fee4 = b.fee
    else 	
	    puts "visit #{v.id} index #{index} is outside of [0..3]"
    end
    v.save

  end
end
