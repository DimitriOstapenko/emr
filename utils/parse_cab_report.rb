# Parse CSV Provided Servces Report from Cab.md for any period (monthly is recommended) and compare with what was submitted by us 
# Provided services includes all claims successfully submitted to OHIP
# We ignore days with less than 10 services - those are from previous pay cicles
#
# CSV Header line:
# ref,hc,vc,prov,name,dob,sdate,pcode,units,sub_fee,errcode
#
require_relative '../config/environment'
require 'csv'
require 'date'

filename = 'provided.csv'

csv_text = File.read(Rails.root.join('export', 'entered.csv')).encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

puts "Scanning CAB.md exported csv report #{filename.inspect}" 

fee = {}
total_fee_submitted = 0
csv.each do |row|
	date = row['sdate']
	next unless date
	if fee[date].present?
	  fee[date][:billed] += row['sub_fee'].tr('$','').to_f
	  fee[date][:svcs] += 1
	else 
	  fee[date] = {:billed => row['sub_fee'].tr('$','').to_f,  :svcs => 1}
	end
end

cab_ttl_billed = cab_ttl_svcs = our_ttl_billed = our_ttl_svcs = 0
fee.each do |day, amt|
	next if amt[:svcs] < 10  # services from previous pay cicles - ignore
	visit_date = Date.strptime(day, '%m/%d/%Y') #- 1.day  #Cab uses record date, not submit date
	day_visits_svcs = day_visits_amt = 0
	visits = Visit.where("date(entry_ts)=?", visit_date)
	visits.map{|v| day_visits_svcs += v.total_insured_services}
	visits.map{|v| day_visits_amt += v.total_insured_fees}
	cab_ttl_billed += amt[:billed]
	cab_ttl_svcs += amt[:svcs]
	our_ttl_billed += day_visits_amt
	our_ttl_svcs += day_visits_svcs
	diff = (day_visits_amt - amt[:billed]).abs > 1 ? '*' : ''
	puts "#{day} : submited by us: #{sprintf("$%.2f", day_visits_amt)}, #{day_visits_svcs} svcs; billed by cab: #{sprintf("$%.2f",amt[:billed])}, #{amt[:svcs]} services #{diff}"
end

puts "Total billed: by us: #{sprintf("$%.2f",our_ttl_billed)}, #{our_ttl_svcs} services;  by cab: #{sprintf("$%.2f",cab_ttl_billed)},  #{cab_ttl_svcs} services"


