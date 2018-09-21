#  Trim filespec to basename in invoces.filename (column renamed from filespec)
#
require_relative '../config/environment'
require 'find'


puts "About to modify filename column in invoices table"
count = 0

Invoice.all.each do |inv|
	next unless inv.filename
	basename = File.basename(inv.filename)
	puts "#{inv.filename} => #{basename}"
	inv.update_attribute(:filename, basename)
	count += 1
end

puts "Modified  #{count} invoices"


