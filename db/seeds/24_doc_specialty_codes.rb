# Import Claim error codes into claim_errors table 
#
require_relative '../../config/environment'
require 'csv'

TABLE='specialty_codes'

source_file = Rails.root.join('lib', 'seeds','specialty_codes.csv')
abort "Source file does not exist." unless File.exists?(source_file)

puts "About to seed #{TABLE} from file #{source_file}"
csv_text = File.read(source_file)
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', col_sep: ',')

SpecialtyCode.destroy_all
codes = 0
csv.each do |row|
  code = row['code']
  puts code
  next unless code.present?
  code.strip! 
  descr = row['descr'].strip
  codes += 1 

#puts "code: #{code.inspect} : #{descr.inspect}"
  code_obj = SpecialtyCode.new(code: code, description: descr)
  if code_obj.save		         
	  puts "#{code_obj.code} #{code_obj.descr} saved"
  else
	  puts 'Problem line: ', code_obj.inspect
          puts code_obj.errors.full_messages
  end
end

puts "Imported #{codes} codes. Now #{SpecialtyCode.count} codes in a #{TABLE} table"
