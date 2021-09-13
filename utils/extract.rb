# delete patients and all dependent data  updated before given date

require_relative '../config/environment'

patients = Patient.where("created_at < '2021-08-31'")

i = 0
patients.each do |p|
  puts i
  i+=1
  p.destroy!

end
