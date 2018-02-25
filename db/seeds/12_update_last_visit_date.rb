#
# Update last visit date in patients from visits table
# 

require_relative '../../config/environment'

puts "About to update patients.last_visit_date"

Patient.first(100).each do |p|
#  puts "patient : #{p.id}"

  last_visit = Visit.where(patient_id: p.id).order(:entry_ts).limit(1)

  if last_visit.blank?
     puts "#{p.id} : no visits"
  else
     ts =  last_visit[0].entry_ts.in_time_zone("UTC") rescue nil
     p.last_visit_date = ts 
     puts " #{p.id} : #{p.last_visit_date}" 
     p.save
  end
  
end


