# Import Claim error codes into claim_errors table 
#
require_relative '../../config/environment'
require 'csv'

TABLE='district_codes'

source_file = Rails.root.join('lib', 'seeds','2014_district_codes.csv')
abort "Source file does not exist." unless File.exists?(source_file)

puts "About to seed #{TABLE} from file #{source_file}"

DistrictCode.destroy_all

code = descr = ''
codes = 0
lines = File.readlines source_file
lines.each do |line|
  (code,place,dtype,mort,county,lhin) = line.split(',').collect(&:strip)
  next unless code.present? && code.match(/^[[:digit:]]{,4}$/)
  code_obj = DistrictCode.new(code: code, place: place, dtype: dtype, m_or_t: mort, county: county, lhin: lhin)
  if code_obj.save		         
	  puts "#{code} #{descr} saved"
	  codes += 1
  else
	  puts 'Problem line: ', code_obj.inspect
          puts code_obj.errors.full_messages
  end
end

puts "Imported #{codes} codes. Now #{DistrictCode.count} codes in a #{TABLE} table"
