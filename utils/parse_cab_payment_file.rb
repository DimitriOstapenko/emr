#
# Seed patient table
#

# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'date'
require 'csv'

#num,ref,X,ohip_num,vc,XX,prov,name,dob,group,XX,XXX,sdate,proc_code,units,XXXX,sub_fee,pd_fee,XXXXX,XXXXXX,XXXXXXX

puts "About to scan CAB.md monthly payment file and calculate payments for each doctor" 

#csv_text = File.read(Rails.root.join('export', 'EO_June.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv_text = File.read(Rails.root.join('export', 'June.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )   # .first(200)

def valid_date?( str, format="%m/%d/%Y" )
  Date.strptime(str,format) rescue false
end

fee = {}
total_fee_submitted = 0
csv.each do |row|
#        puts row.to_hash
	date = row['sdate']
	next unless date

	if fee[date].present?
	  fee[date][:billed] += row['sub_fee'].tr('$','').to_f
	  fee[date][:paid] += row['pd_fee'].tr('$','').to_f
	  fee[date][:svcs] += 1
	else 
	  fee[date] = {:billed => row['sub_fee'].tr('$','').to_f, :paid => row['pd_fee'].tr('$','').to_f, :svcs => 1}
	end
end

total_submitted_services = total_submitted_fees = total_billed =  total_billed_svcs = total_paid = 0
fee.each do |day, amt|
	total_billed += amt[:billed]
	total_billed_svcs += amt[:svcs]
	total_paid += amt[:paid]

	submitted_fees_this_day = submitted_services_this_day = 0
	visits = Visit.where("(status=? OR status=?) AND date(entry_ts)=?", BILLED, PAID, Date.strptime(day,'%m/%d/%Y'))
	visits.map{|v| submitted_fees_this_day += v.total_insured_fees}
	visits.map{|v| submitted_services_this_day += v.total_insured_services}
	total_submitted_fees += submitted_fees_this_day
	total_submitted_services += submitted_services_this_day
	puts  "#{day} submited: #{submitted_fees_this_day.round(2)} (#{submitted_services_this_day}); billed: #{amt[:billed].round(2)} (#{amt[:svcs]}): paid : #{amt[:paid].round(2)} "
end

puts "Submitted by us: $#{total_submitted_fees.round(2)} (#{total_submitted_services}); Billed by CAB: $#{total_billed.round(2)} (#{total_billed_svcs}) ; Paid by OHIP: $#{total_paid.round(2)}"

