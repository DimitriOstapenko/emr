#
# Parse monthly remittance advice (RA) file from MOH, get totals for each doctor and each day 
#
# ex: PG0078.398
#
require_relative '../config/environment'
require 'date'
require 'csv'

month = ARGV[0]
unless month && month.match('^\w{3}$')
  puts "Usage: ruby proggy <MON>"
  exit
end

dir  = EDT_PATH.join(month)
unless File.directory?(dir)
  puts "Directory does not exist. Try something else"
  exit
end

ra_file = ''
Find.find( dir ) do |path|
	next unless path.match('P[A-L]\d{4}\.\d{3}')
	ra_file = path
end

def HR1(s) 
   group_no = s[7,4]
   deposit_date = s[21,8]
   payee_name = s[29,30]
   total_amount = s[59,9].to_i rescue 0
   negative = s[68] == '-'
   total_amount = -total_amount if negative
   deposited_as = s[69,8].match('99999999') ? 'Direct Deposit' : "Cheque # #{s[69,8]}"

   puts "Group : #{group_no} Deposit date: #{deposit_date} Payee: #{payee_name} Total amount: #{total_amount} Paid by #{deposited_as}"
end

def HR2(s)
   billing_agent = s[3,30].strip
   billing_agent = 'None' if billing_agent.blank?
   payee_address = s[33,25]	
   puts "Biling agent: #{billing_agent} Payee address: #{payee_address}"
end

def HR3(s)
   city_prov_postal = s[3,25].strip
   rest = s[28,25].strip
   puts "Payee address 2: #{city_prov_postal}  #{rest}"
end

def HR4(s)
   claim_no = s[3,11]
   tr_type = s[14] # == '1' ? 'OR' : 'ADJ' # Original or Adjustment claim?
   provider_no = s[15,6]
   specialty = s[21,2]
   accounting_no = s[23,8]
   pat_lname = s[31,14].strip    # spaces except for RMB claims
   pat_fname = s[45,5].strip     # spaces except for RMB claims
   prov_code = s[50,2]
   hc_num = s[52,12]
   hc_ver = s[64,2]
   pmt_pgm = s[66,3]
   svc_loc = s[69,4]
   moh_group_id = s[73,4]

   puts "MOH Ref: #{claim_no} TrType: #{tr_type} Provider: #{provider_no} Spec: #{specialty} Acc: #{accounting_no} Pat: #{pat_lname} #{pat_fname} Prov:#{prov_code} #HC: #{hc_num} #{hc_ver} #{pmt_pgm} #{svc_loc} #{moh_group_id}"
end

def HR5(s)
   claim_no = s[3,11]
   tr_type = s[14] == '1' ? 'OR' : 'ADJ' # Original or Adjustment claim?
   svc_date = s[15,8]
   units = s[23,2]
   svc_code = s[25,5]
   amt_subm = s[31,6].to_f/100
   amt_paid = s[37,6].to_f/100
   amt_paid = -amt_paid if s[43] == '-'
   code = s[44,2]

   puts "#{claim_no} #{tr_type} #{svc_date} #{units} #{svc_code} #{amt_subm} #{amt_paid} #{code}"
end

puts "About to parse RA MOH file #{ra_file}" 
content = File.readlines ra_file

claim_count = 0
content.each_with_index do |str, i| 
  hdr = str[0,3]
  case hdr 
  when 'HR1'
	  HR1(str)
  when 'HR2'
	  HR2(str)
  when 'HR3'
	  HR3(str)
  when 'HR4'
	  claim_count += 1
	  HR4(str)
  when 'HR5'
	  HR5(str)
  else
  end	  

end

puts "Total claims in this file: #{claim_count}"

