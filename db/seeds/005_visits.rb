#
# Seed visits table from CSV file
#
require_relative '../../config/environment'
#require 'date'
require 'csv'

if ARGV[0].nil?
    puts "Usage: ./script.rb yyyy-mm-dd"
    exit
end

begin
target_date = ARGV[0].to_date
  rescue
    puts 'Invalid date'
    exit
end

added = 0
csv_text = File.read(Rails.root.join('lib', 'seeds', 'schedule_data.csv'))

puts "About to add visits for #{target_date} to visits table; id will be autoassigned" 
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   #.first(10)
  
csv.each do |row|
  visit_date = row['entry_date']
  date = Date.strptime(row['entry_date'],"%m/%d/%Y") rescue nil
  next if date != target_date

  doc_code = row['doc_code']
  doc = Doctor.find_by(doc_code: doc_code) if !doc_code.blank?
  unless doc
    puts "Doctor not found: #{doc_code}"
    next
  end
  
  pat_id = row['pat_code']
  pat_id = 70761 if pat_id == 70727
  pat_id = 70762 if pat_id == 70734 
  pat_id = 70763 if pat_id == 70736 
  pat_id = 70764 if pat_id == 70738 
  pat_id = 70765 if pat_id == 70739



  unless Patient.exists?(pat_id)
    puts "Patient not found: #{pat_id}" 
    next
  end 

  visit = patient.visits.build  entry_ts: datetime,  # id: row['ordno'],
 		     		doc_id: doc.id,
		     		doc_code: doc_code,
		     		status: row['status'],
		     		proc_code: row['proc_code'],
		     		diag_code: row['diagnosis'],
#		     		notes: row['importance'],
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
