# Import paid claims from MOH monthly remittance advice (RA) file, load records into following tables:
#  - claims
#  - services
#  - ra_accounting
#  - ra_messages
#
#  ARGV: target month's letter, optional. If none given, current month will be used
#
# Files like: PG0078.398 (jun) in EDT
#
# Ignore already processed files
#
require_relative '../../config/environment'
require 'date'

abort "EDT directory does not exist." unless File.directory?(EDT_PATH)

$ra_msg = nil
$hr8_messages = ''
$deposit_date = nil
this_month = Date.today.month
this_month_name = Date.today.strftime("%B")
this_letter = ARGV[0] || ('A'..'Z').to_a[this_month-1]
path = EDT_PATH.join("P#{this_letter.upcase}#{GROUP_NO}.*")
this_month_file = Dir.glob(path).first rescue nil

abort "File not found: #{path}" unless this_month_file.present?

if this_month_file.present?
   puts "#{this_month_name} file exists (#{this_month_file})"	
   base = File.basename(this_month_file)
   if Claim.exists?(ra_file: base)
     abort ".. and is already imported. Use delete_ra_file_claims.rb <letter> script to delete"	
   else 
     puts ".. and needs importing"
     RA_FILE = this_month_file
     RA_BASENAME = base
   end
end 

# Total, payee, deposit date : once per file
def HR1(s) 
   group_no = s[7,4]
   $deposit_date = s[21,8].to_date rescue '1900-01-01'
   payee_name = s[29,30]
   total_amount = s[59,9].to_i rescue 0
   negative = s[68] == '-'
   total_amount = -total_amount if negative
   deposited_as = s[69,8].match('99999999') ? 'Direct Deposit' : "Cheque # #{s[69,8]}"
   puts "file: #{RA_BASENAME} : Group : #{group_no} Deposit date: #{$deposit_date} Payee: #{payee_name} Total amount: $#{total_amount/100.0} Payment method: #{deposited_as}"

   $ra_msg = RaMessage.new(ra_file: RA_BASENAME, date_paid: $deposit_date, group_no: group_no, payee_name: payee_name, amount: total_amount, pay_method: deposited_as)
end

# Addr 1 : once per file
def HR2(s)
   billing_agent = s[3,30].strip
   billing_agent = 'None' if billing_agent.blank?
   payee_address = s[33,25]	
#   puts "Biling agent: #{billing_agent} Payee address: #{payee_address}"

   puts("HR2: msg: error updating address, billing agent") unless $ra_msg.update_attributes(:payee_addr => payee_address, :bil_agent => billing_agent)
end

# Addr 2 : once per file
def HR3(s)
   city_prov_postal = s[3,25].strip
   rest = s[28,25].strip
#   puts "Payee address 2: #{city_prov_postal}  #{rest}"
end

# Claim header: once per claim
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

# Claim body; once per each item in a claim
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

# Balance Forward Record – Health Reconciliation; once per file (not used in any files jan-jun 2018)
def HR6(s)
   bal_fwd = s[3,9]
   bal_fwd = -bal_fwd if s[12] == '-'
   adv_amt = s[13,9]
   adv_amt = -adv_amt if s[22] == '-'
   red_amt = s[23,9] 
   red_amt = -red_amt if s[32] == '-'
   other_deduct = s[33,9]
   other_deduct = -other_deduct if s[42] == '-'
   puts 'HR6 is not saved currently! Modify if you see this message'
end

# Accounting Transaction Record – Health Reconciliation; once per file
def HR7(s)
  tr_codes = { '10' => 'Recovery of Advance', '20' => 'Reduction', '30' => 'Unused', '40' => 'Payment', '50' => 'Estimated Payment For Unprocessed Claims', '70' => 'Unused'  }
  tr_code_num = s[3,2]
  tr_code = tr_codes[tr_code_num]
  tr_date = s[6,8].to_date rescue '1900-01-01'
  tr_amt = s[14,8].to_i
  tr_amt = -tr_amt if s[22] == '-'
  tr_msg = s[23,50]

  acc_rec = RaAccount.new(tr_code: tr_code, tr_date: tr_date, tr_amt: tr_amt, tr_msg: tr_msg, ra_file: RA_BASENAME, date_paid: $deposit_date)  
  acc_rec.save
end

# Message Facility Record – Health Reconciliation 
def HR8(s)
  $hr8_messages << s[3,70] + "\n"
end
  
content = File.readlines RA_FILE 
claim = nil
claims = services = -1
content.each do |str| 
  hdr = str[0,3]
  case hdr 
  when 'HR1'
	  HR1(str)
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
  when 'HR6'
	  HR6(str)
  when 'HR7'
          HR7(str)
  when 'HR8'
          HR8(str)
  else
  end	  
end

if $ra_msg.update_attribute(:msg_text, $hr8_messages)  
   puts "messages saved to ra_messages table"
else
   puts "error saving messages to ra_messages table"
end

puts "Imported #{claims} claims, #{services} services"
puts "Please run process_paid_claims.rb now to fix attributes and find missing claims"
