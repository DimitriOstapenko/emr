#
# Seed visits table from CSV file
#

# Next 3 lines allow to run it in stand-alone mode
require_relative '../../config/environment'
require 'date'
require 'csv'

puts "About to update visits table; validity checks  should be off" 

csv_text = File.read(Rails.root.join('lib', 'seeds', 'schedule_data.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   #.first(10)

def ts( str, format="%m/%d/%Y %k:%M:%S" )
	DateTime.strptime(str,format) rescue DateTime.new(1900,1,1)
end

#Visit.destroy_all

added = 0
csv.each do |row|
  visit_id = row['ordno'] 
  next if Visit.exists?(visit_id)

  doc_code = row['doc_code']
  doc = Doctor.find_by(doc_code: doc_code) if !doc_code.blank?
  unless doc
    puts "Doctor not found: #{doc_code}"
    next
  end
  
  pat_id = row['pat_code']
  unless Patient.exists?(pat_id)
    puts "Patient not found: #{pat_id}" 
    next
  end 

  patient = Patient.find(pat_id)
 
  datetime = ts(row['entry_date'] +' '+ row['entry_time'])
  
  visit = patient.visits.build id: row['ordno'],
	             		entry_ts: datetime, 
 		     		doc_id: doc.id,
		     		doc_code: doc_code,
		     		status: row['status'],
		     		proc_code: row['proc_code'],
		     		diag_code: row['diagnosis'],
		     		notes: row['importance'],
		     		duration: row['duration'], 
		     		vis_type: row['enctype'],
		     		entry_by: row['entry_by']

  if visit.save
     patient.save
     added += 1
#     puts "*** #{visit.id} : #{datetime} saved"
  else
     puts "Problem visit: #{visit.id}"
     puts visit.errors.full_messages
  end

end

puts "#{Visit.count} records are now in visits table. Added #{added} visits. "
