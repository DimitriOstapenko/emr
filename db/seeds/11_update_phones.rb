#
# Clean up phone numbers in Patient and Doctor tables - remove whitespace and dashes 
#
#

require_relative '../../config/environment'

Patient.all.each do |p|
  puts "patient : #{p.id}"

  if !p.phone.blank?
    p.phone.tr!('- ','')
    p.save
  end
  
  if !p.mobile.blank?
    p.mobile.tr!('- ','')
    p.save
  end
end

Doctor.all.each do |d|
  puts "doc : #{d.id}"

  if !d.phone.blank?
    d.phone.tr!('- ','')
    d.save
  end
  
  if !d.mobile.blank?
    d.mobile.tr!('- ','')
    d.save
  end
end

