#
# Set doc_id field in billings and visits table to match doctor.id 
#

# need next line if run stand-alone
 require_relative '../../config/environment'

Procedure.all.each do |p|

  if Billing.find_by(proc_code: p.code)
    puts "found: #{p.code} - kept"
  else
    puts "not found in billing: #{p.code} - disabled" 
    p.active = 0 
    p.save
  end

end


