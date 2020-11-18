# Go through all patients and validate their ON health card
#
require_relative '../config/environment'

puts "will go through all Ontario patients and validate their health cards"           

Patient.all.each do |pat|
  next unless pat.pat_type == 'O'
  next unless pat.ohip_num.present?
  puts "#{pat.id} is invalid" if pat.card_invalid?
#  pat.validate_card
end


