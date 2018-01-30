#
# Seed visits table
#

#require 'date'
#require 'csv'
#csv_text = File.read('/Users/dmitri/walkin/lib/seeds/schedule_data.csv')

csv_text = File.read(Rails.root.join('lib', 'seeds', 'schedule_data.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   #  .first(1000)

def ts( str, format="%m/%d/%Y %k:%M:%S" )
	DateTime.strptime(str,format) rescue DateTime.new(1900,1,1)
end

Visit.destroy_all

all = 0
found = 0 
csv.each do |row|
#  puts row.to_hash

  all += 1
  patient_id = row['pat_code']
  
  unless Patient.exists?(patient_id)
    puts "not found #{patient_id}" 
    next
  end 

  patient = Patient.find(patient_id)
 
  found += 1
  datetime = ts(row['entry_date'] +' '+ row['entry_time'])
  
  visit = patient.visits.build id: row['ordno'],
	             		entry_ts: datetime, 
 		     		doc_id: 1,
		     		doc_code: row['doc_code'],
		     		status: row['status'],
		     		proc_code: row['proc_code'],
		     		diag_code: row['diagnosis'],
		     		notes: row['importance'],
		     		duration: row['duration'], 
		     		vis_type: row['enctype'],
		     		entry_by: row['entry_by']

  if visit.save
     patient.save
#     puts "*** #{visit.id} : #{datetime} saved"
  else
     puts "Problem visit: #{visit.id}"
     puts visit.errors.full_messages
  end

end

puts "#{all} rows scanned; #{found} rows had associated patient record" 
puts "#{Visit.count} records added to visits table "
