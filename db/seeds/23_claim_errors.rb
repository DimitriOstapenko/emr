# Import Claim error codes into claim_errors table 
#
require_relative '../../config/environment'
require 'csv'

TABLE='claim_errors'

source_file = Rails.root.join('lib', 'seeds','claim_errors.csv')
abort "Source file does not exist." unless File.exists?(source_file)

puts "About to seed #{TABLE}"
csv_text = File.read(source_file)
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

ClaimError.destroy_all
codes = 0
csv.each do |row|
  code = row['code']
  next unless code.present?
  code.strip! 
  descr = row['descr'].strip
  codes += 1 

#puts "code: #{code.inspect} : #{descr.inspect}"
  err_obj = ClaimError.new(code: code, descr: descr)
  if err_obj.save		         
	  puts "#{err_obj.code} #{err_obj.descr} saved"
  else
	  puts 'Problem line: ', err_obj.inspect
          puts err_obj.errors.full_messages
  end
end

puts "Imported #{codes} codes. Now #{ClaimError.count} codes in a #{TABLE} table"
