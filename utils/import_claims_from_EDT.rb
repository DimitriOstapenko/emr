#
# Import paid claims from monthly remittance advice (RA) file from MOH, load records into 'claims' and 'services' tables
#
# Files like: PG0078.398 (jun) in EDT/<MON>
#
require_relative '../config/environment'
require 'date'
require 'find'

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

Find.find( dir ) do |path|
	next unless path.match('P[A-L]\d{4}\.\d{3}')
	RA_FILE = path
	RA_BASENAME = File.basename(path)
end

# Total, payee, deposit date
def HR1(s) 
   group_no = s[7,4]
   $deposit_date = s[21,8].to_date rescue '1900-01-01'
   payee_name = s[29,30]
   total_amount = s[59,9].to_f/100 rescue 0
   negative = s[68] == '-'
   total_amount = -total_amount if negative
   deposited_as = s[69,8].match('99999999') ? 'Direct Deposit' : "Cheque # #{s[69,8]}"

   puts "file: #{RA_BASENAME} : Group : #{group_no} Deposit date: #{$deposit_date} Payee: #{payee_name} Total amount: $#{total_amount} Payment method: #{deposited_as}"
end

# Addr 1
def HR2(s)
   billing_agent = s[3,30].strip
   billing_agent = 'None' if billing_agent.blank?
   payee_address = s[33,25]	
   puts "Biling agent: #{billing_agent} Payee address: #{payee_address}"
end

# Addr 2
def HR3(s)
   city_prov_postal = s[3,25].strip
   rest = s[28,25].strip
   puts "Payee address 2: #{city_prov_postal}  #{rest}"
end

# Claim header
# claim_no:string provider_no:string accounting_no:string pat_lname:string pat_fname:string province:string 
# ohip_num:string ohip_ver:string pmt_pgm:string moh_group_id:string cabmd_ref:string visit_id:integer ra_file:string date_paid:date
def HR4(s)
   claim_no = s[3,11]
   tr_type = s[14] 		 # Original (1) or Adjustment (2) claim?
   provider_no = s[15,6]
   specialty = s[21,2]
   accounting_no = s[23,8]
   pat_lname = s[31,14].strip    # spaces except for RMB claims
   pat_fname = s[45,5].strip     # spaces except for RMB claims
   province = s[50,2]
   ohip_num = s[52,12].strip     # Right padded with spaces!
   ohip_ver = s[64,2]
   pmt_pgm = s[66,3]
   svc_loc = s[69,4]
   moh_group_id = s[73,4]

   Claim.new(claim_no: claim_no, provider_no: provider_no, accounting_no: accounting_no, pat_lname: pat_lname, pat_fname: pat_fname, 
	     province: province, ohip_num: ohip_num, ohip_ver: ohip_ver, pmt_pgm: pmt_pgm, moh_group_id: moh_group_id, ra_file: RA_BASENAME, date_paid: $deposit_date )
end

# Claim body
# claim_no:string tr_type:integer svc_date:date units:integer svc_code:string amt_subm:integer amt_paid:integer errcode:string
def HR5(s)
   claim_no = s[3,11]
   tr_type = s[14]  		# Original (1) or Adjustment (2) claim?
   svc_date = s[15,8].to_date rescue '1900-01-01'
   units = s[23,2].to_i rescue 1
   svc_code = s[25,5]		# Not saved
   amt_subm = s[31,6].to_i
   amt_paid = s[37,6].to_i
   amt_paid = -amt_paid if s[43] == '-'
   errcode = s[44,2].strip
   
   Service.new(claim_no: claim_no, tr_type: tr_type, svc_date: svc_date, units: units, svc_code: svc_code, amt_subm: amt_subm, amt_paid: amt_paid, errcode: errcode)

end

already_done = true if Claim.exists?(ra_file: RA_BASENAME)

content = File.readlines RA_FILE 
claim = nil
claims = services =0
content.each do |str| 
  hdr = str[0,3]
  case hdr 
  when 'HR1'
	  HR1(str)
	  if already_done
            puts "#{RA_BASENAME} was imported already - terminating"
	    exit
	  end
  when 'HR2'
	  HR2(str)
  when 'HR3'
	  HR3(str)
  when 'HR4'
	  claim.save if claim.present?
	  claim = HR4(str)
	  claims += 1
  when 'HR5'
	  service = HR5(str)
	  claim.services.build(service.attributes)
	  services += 1
  else
  end	  

end

puts "Imported #{claims} claims, #{services} services"
