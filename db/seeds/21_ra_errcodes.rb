# Import RA error codes into ra_errcodes table 
#
require_relative '../../config/environment'

source_file = Rails.root.join('lib', 'seeds','ra_errcodes.txt')
abort "Source file does not exist." unless File.exists?(source_file)

codes = 0
RaErrcode.destroy_all
lines = File.readlines source_file 
lines.each do |line|
  (empty,code,msg) = line.split(/^\s*(\w{2})\s+(.+)$/)
  msg.strip!
  puts "code: #{code.inspect} : #{msg.inspect}"
  codes += 1 if code.present?

  obj = RaErrcode.new(code: code, message: msg)
  obj.save
end

puts "Imported #{codes} codes. Now #{RaErrcode.count} codes in a table"
