# Parse CSV payment file from CAB.md (created by CSV export of xls report) and get totals for each day for all doctors 
#
# CSV Header line:
# ref,hc,vc,prov,name,dob,sdate,pcode,units,sub_fee,errcode
#
require_relative '../config/environment'
require 'csv'
require 'date'

#filename = 'entered.csv'
filename = 'provided.csv'

csv_text = File.read(Rails.root.join('export', 'entered.csv')).encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

puts "Scanning CAB.md exported csv report #{filename.inspect}" 

fee = {}
total_fee_submitted = 0
csv.each do |row|
#        puts row.to_hash
	date = row['sdate']
	next unless date

	if fee[date].present?
	  fee[date][:billed] += row['sub_fee'].tr('$','').to_f
	  fee[date][:svcs] += 1
	else 
	  fee[date] = {:billed => row['sub_fee'].tr('$','').to_f,  :svcs => 1}
	end
end

total_submitted_services = total_submitted_fees = total_billed =  total_billed_svcs = 0
fee.each do |day, amt|
	total_billed += amt[:billed]
	total_billed_svcs += amt[:svcs]
	puts "#{day} :  submited: #{sprintf("$%.2f",amt[:billed])}, #{amt[:svcs]} services"
end

puts "Total billed: #{sprintf("$%.2f",total_billed)},  #{total_billed_svcs} services"

sdate = Date.strptime(fee.keys.first, '%m/%d/%Y')
edate = Date.strptime(fee.keys.last, '%m/%d/%Y')
visits = Visit.where("date(entry_ts) IN (?)", (sdate..edate))

vtotal = 0
visits.each do |v|
 vtotal += v.total_fee
end

puts "Total fee submitted by us for the same timeframe: #{sprintf("$%.2f",vtotal)}"


