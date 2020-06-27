# Update procedures using current fee schedule in txt file
#                                              POS  LEN FORMAT
# First four characters of Fee Schedule code :  1    4    X   ANNN
# Effective Date                                5    8    D   
# Termination Date                              13   8    D   9999999999 for indefinite
# Provider Fee                                  21   11   N   Dollars (4 decimal places)
# Assistant's fee                               32   11   N   Zero filled
# Specialist fee                                43   11   N   Dollars (4 decimal places)
# Anaesthetist fee                              54   11   N   Zero filled
# Non-Anaesthetist's fee                        65   11   N   Zero filled
#
require_relative '../config/environment'

puts "Will update procedures table with new data from current schedule" 

text = File.readlines(Rails.root.join('lib', 'seeds', 'fee_schedule.txt'))

ttl_count = created = updated = 0
text.each do |s|
  code = s[0,4]+'A'
  proc = Procedure.find_by(code: code) || Procedure.new(code: code)
  (eff,term, proc.prov_fee, proc.ass_fee, proc.spec_fee, proc.ana_fee, proc.non_ana_fee) = s[4,8], s[12,8], s[20,11].to_f/10000, s[31,11].to_f/10000, s[42,11].to_f/10000, s[53,11].to_f/10000, s[64,11].to_f/10000
  proc.eff_date = eff.to_date rescue '2099-01-01'.to_date
  proc.term_date = term.to_date rescue '2099-01-01'.to_date
  proc.cost = proc.prov_fee
  proc.ptype = 1

#  puts proc.inspect

  ttl_count += 1
  if proc.save
     puts "#{proc.id} : #{proc.code} saved"
  else
     puts 'Problem procedure: ', proc.code
     puts proc.errors.full_messages
  end

end

puts "Ttl: #{ttl_count} created/updated"

