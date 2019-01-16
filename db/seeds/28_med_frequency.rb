# Import Medication formats into medformats table
#
require_relative '../../config/environment'
require 'csv'

TABLE='med_frequencies'

source_file = Rails.root.join('lib', 'seeds','med_freq.csv')
abort "Source file does not exist." unless File.exists?(source_file)

puts "About to seed #{TABLE} from file #{source_file}"

MedFrequency.destroy_all

name = descr = ''
names = 0
lines = File.readlines source_file
lines.each do |line|
  (name,descr) = line.split(',').collect(&:strip)
  next unless name.present? 
  obj = MedFrequency.new(name: name, descr: descr)
  if obj.save		         
	  puts "#{name} #{descr} saved"
	  names += 1
  else
	  puts 'Problem line: ', obj.inspect
          puts obj.errors.full_messages
  end
end

puts "Imported #{names} medication frequencies. Now #{MedFrequency.count} codes in a #{TABLE} table"
