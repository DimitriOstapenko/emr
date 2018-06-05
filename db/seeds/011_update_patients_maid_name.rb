#
# Seed patient table
#

# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'date'
require 'csv'

puts "About to update patients with maiden name. "

csv_text = File.read(Rails.root.join('lib', 'seeds', 'patdata.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

updated = 0
csv.each do |row|
  @patient = Patient.find(row['patid']) rescue next
  next if row['maid_name'].blank?
  @patient.update_attribute(:maid_name, row['maid_name'])
  puts "#{@patient.id} : #{@patient.lname} : #{@patient.maid_name}"
  updated +=1
end

puts "#{Patient.count} patients now in patients table. Updated  #{updated} patients."


