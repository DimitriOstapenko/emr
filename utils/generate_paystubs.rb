#
# Generate pay stub for each doctor with stats for each day they worked using CSV file created from Cab.md report
#
# CSV file naming syntax : <provider_no>_<name>.csv
# Files are downloaded from cab.md reports section and stored in separate directory for given month
# CSV Header row:
# ref,X,ohip_num,vc,XX,prov,name,dob,group,XX,XXX,sdate,proc_code,units,XXXX,sub_fee,pd_fee,XXXXX,XXXXXX,XXXXXXX

# Next 3 lines allow to run it in stand-alone
require_relative '../config/environment'
require 'csv'
require 'find'

#csv_text = File.read(Rails.root.join('export', 'JUN', '015539_OSTAPENKO_JUN.csv')).force_encoding('BINARY').encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')

month = ARGV[0]
unless month && month.match('^\w{3}$')
  puts "Usage: ruby proggy <MON>" 
  exit
end

dir  = EXPORT_PATH.join(month)
unless File.directory?(dir)
  puts "Directory does not exist. Try something else"
  exit
end

def do_file(path)
basename = File.basename(path)
unless basename.match(/^\d{6}\w+\.csv$/)
#  puts "#{path} ignored - provider_no must be 6 digits"
  return
end

(fname, ext) = basename.split('.') 
(provider_no, lname) = fname.split('_') 
doc = Doctor.find_by(provider_no: provider_no)

csv_text = File.read(path).encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?')
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' )  

puts '',"Monthly report for dr. #{doc.lname}, #{doc.fname} (#{doc.provider_no}) Group No: #{GROUP_NO}",''

fee = {}
csv.each do |row|
	date = row['sdate']
	next unless date

	if fee[date].present?   # several services on the same visit
	  fee[date][:billed] += row['sub_fee'].tr('$','').to_f
	  fee[date][:paid] += row['pd_fee'].tr('$','').to_f
	  fee[date][:svcs] += 1
	else 
	  fee[date] = {:billed => row['sub_fee'].tr('$','').to_f, :paid => row['pd_fee'].tr('$','').to_f, :svcs => 1}
	end
end

total_patients = total_submitted_services = total_submitted_fees = total_billed =  total_billed_svcs = total_paid = days = total_cash = 0
fee.each do |day, amt|
	total_billed += amt[:billed]
	total_billed_svcs += amt[:svcs]
	total_paid += amt[:paid]
	days += 1

	submitted_fees_this_day = submitted_services_this_day = received_cash_this_day = 0
	visits = Visit.where("(status=? OR status=?) AND date(entry_ts)=? AND doc_id=?", BILLED, PAID, Date.strptime(day,'%m/%d/%Y'), doc.id)
	visits.map{|v| submitted_fees_this_day += v.total_insured_fees}
	visits.map{|v| submitted_services_this_day += v.total_insured_services}
	visits.map{|v| received_cash_this_day += v.total_cash}
	total_patients += visits.count
	total_submitted_fees += submitted_fees_this_day
	total_submitted_services += submitted_services_this_day
	total_cash += received_cash_this_day
	dt = Date.strptime(day,'%m/%d/%Y')
	puts  "#{dt} patients: #{visits.count} submited: $#{submitted_fees_this_day.round(2)} (#{submitted_services_this_day} svcs); billed: $#{amt[:billed].round(2)} (#{amt[:svcs]} svcs): paid : $#{amt[:paid].round(2)}  cash: $#{received_cash_this_day}"
end

puts
puts "Days worked: #{days} Patients seen: #{total_patients} Services billed: #{total_submitted_services}"
puts "Submitted by us: $#{total_submitted_fees.round(2)} (#{total_submitted_services} svcs); Billed by CAB: $#{total_billed.round(2)} (#{total_billed_svcs} svcs) ; Paid by OHIP: $#{total_paid.round(2)} Cash received: $#{total_cash.round(2)}"
return [total_paid, total_billed_svcs] 
end

puts "Will read payment CSV files from #{dir} for each doctor"

ttl_fees = ttl_svcs = 0
Find.find( dir ) do |path| 
	(fees,svcs) = do_file(path)
	ttl_fees += fees if fees
	ttl_svcs += svcs if svcs
end

puts "Grand total Fees: $#{ttl_fees.round(2)}; Services: #{ttl_svcs}"

