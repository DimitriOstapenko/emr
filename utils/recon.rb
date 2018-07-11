#
# Parse monthly remittance advice (RA) file from MOH, get totals for each doctor and each day 
#
# ex: PG0078.398
#
require_relative '../config/environment'
require 'date'
require 'csv'

sdate = ARGV[0]
date = Date.parse(sdate)
unless sdate && date
  puts "Usage: ruby proggy <MON>"
  exit
end

puts "using #{date} as start date"

Visit.where("date(entry_ts) >= ?", date).each do |v| 
   next if v.status == PAID
   Claim.find_by(accounting_no: v.export_file)
   puts "Visit: #{v.id} Pat : #{v.patient_id} : status : #{v.status_str}"
end
