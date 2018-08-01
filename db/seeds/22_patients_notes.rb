# Extract patient notes from CSV file and insert them before notes in EMR, if any
#

# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'yomu'
require 'csv'

puts "About to add old notes to notes field in patients table."

csv_text = File.read(Rails.root.join('lib', 'seeds', 'patdata_notes.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

added = 0
csv.each do |row|
  pat_id = row['patid']
  ohip_num = row['ohip'].gsub(/\D/,'') rescue ''
  oldnotes_rtf = row['notes']	
  next unless oldnotes_rtf.present? && ohip_num.present?
  puts ohip_num
  pat = Patient.find_by(ohip_num: ohip_num ) rescue nil
  next unless pat.present?

  added += 1
  notes = pat.notes
  oldnotes = Yomu.read :text, oldnotes_rtf
  puts "#{pat_id} : #{ohip_num}: #{oldnotes}"
  
  if pat.update_attribute(:notes, "#{oldnotes} \n #{notes}")
     puts "* Pat #{pat.id}  - notes updated" 	  
  else
     puts "*** Error updating notes for #{pat.id}: #{pat.errors.full_messages}"
  end

end

puts "Added notes to #{added} patients with mathcing ohip numbers."


