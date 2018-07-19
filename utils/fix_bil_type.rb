# Go through all visits and check if bil types correspond to proc type
# 

require_relative '../config/environment'
require 'date'

incorrect_count = correct_count = 0
Visit.all.each do |v|

  if v.proc_code 
    p = Procedure.find_by(code: v.proc_code)
    next unless p.present?
    if p.cash? 
       if v.bil_type == CASH_BILLING
         correct_count += 1 
	 v.update_attribute(:bil_type, CASH_BILLING)
       else
         incorrect_count +=1
         puts "#{v.proc_code} : #{v.bil_type_str}"
       end
    else
       if v.bil_type != CASH_BILLING
         correct_count += 1 
       else
         incorrect_count +=1
         puts "#{v.proc_code} : #{v.bil_type_str}"
	 v.update_attribute(:bil_type, HCP_BILLING)
       end
    end
  end
end


puts "Correct: #{correct_count} Incorrect: #{incorrect_count}"
