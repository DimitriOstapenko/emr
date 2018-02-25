#
# Set active to false for procedures not found in billings table
#

# need next line if run stand-alone
 require_relative '../../config/environment'

puts "About to disable procedures not found in billings table"

Procedure.all.each do |p|

  if Billing.find_by(proc_code: p.code)
    puts "found: #{p.code} - kept"
    p.active = 1 
  else
    puts "not found in billing: #{p.code} - disabled" 
    p.active = 0 
  end
  p.save

end


