#
# Validate ohip numbers of all patients;
# Print all validation errors 
# 

require_relative '../config/environment'

puts "Invalid ohip numbers:"

count = 0
Patient.all.each do |p|
  next if p.valid?
  puts "invalid : #{p.id}  #{p.errors.full_messages}" if p.errors[:ohip_num]
  count += 1
end

puts "#{count} patient's health cards out of #{Patient.count} are invalid"

