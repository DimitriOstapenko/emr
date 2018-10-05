# Find and process new error files in EDT directory  
#
#  ARGV: target month's letter, optional. If none given, current month will be used
#
# Files like: EA0078.504  (Jan) in EDT
#
# Ignore already processed files
#
require_relative '../../config/environment'
require 'date'

abort "EDT directory does not exist." unless File.directory?(EDT_PATH)

this_month_name = Date.today.strftime("%B")
this_month_letter = ARGV[0] || THIS_MONTH_LETTER
puts this_month_letter 
path = EDT_PATH.join("E#{this_month_letter.upcase}*.*")
new_files = Dir.glob(path)

abort "File not found: #{path}" unless new_files.any?

# Group/Provider Header Record 
def HX1(s) 
   moh_office_code = s[6,1]
   oper_number = s[17,6]
   group_no = s[23,4]
   provider_no = s[27,6]
   spec_code = s[33,2]
   station_no = s[35,3]
   claim_proc_date = s[38,8].to_date
   
   puts "moh_office_code: #{moh_office_code}", 
	"oper_number: #{oper_number}",
	"group_no: #{group_no}",
	"provider_no: #{provider_no}",
	"spec_code: #{spec_code}",
	"station_no: #{station_no}",
	"claim_proc_date: #{claim_proc_date}"
end #HX1

# Claims Header 1 Record
def HXH(s)
  health_no = s[3,10].to_i
  version_code = s[13,2]
  pat_dob = s[15,8].to_date
  accountning_no = s[23,8].strip
  pmt_pgm = s[31,3]
  payee = s[34,1]
  ref_provider_no = s[35,6]
  master_no = s[41,4]
  pat_adm_date = s[45,8].to_date
  ref_lab_licence = s[53,4]
  service_loc_ind = s[57,4]
  err_code_1 = s[64,3]
  err_code_2 = s[67,3]
  err_code_3 = s[70,3]
  err_code_4 = s[73,3]
  err_code_5 = s[76,3]
  	
   puts "health_no: #{health_no}", 
	"version_code: #{version_code}",
      	"pat_dob: #{pat_dob}",
	"accountning_no: #{accountning_no}",
	"pmt_pgm: #{pmt_pgm}",
	"payee: #{payee}",
	"ref_provider_no: #{ref_provider_no}",
	"master_no: #{master_no}",
	"pat_adm_date: #{pat_adm_date}",
	"ref_lab_licence: #{ref_lab_licence}",
	"service_loc_ind: #{service_loc_ind}",
	"err_code_1: #{err_code_1}",
	"err_code_2: #{err_code_2}",
	"err_code_3: #{err_code_3}",	
	"err_code_4: #{err_code_4}",
	"err_code_5: #{err_code_5}"
end #HXH

# Claims Header 2 Record (RMB claims only)
def HXR(s)
  reg_no = s[3,12] # HN for different provinces ranges from 8 to 12 chars
  pat_last_name = s[15,9].strip
  pat_first_name = s[24,5].strip
  pat_sex = s[29,1]
  prov_code = s[30,2]

   puts "reg_no: #{reg_no}",
        "pat_last_name: #{pat_last_name}",
        "pat_first_name: #{pat_first_name}",
	"pat_sex: #{pat_sex}",
	"prov_code: #{prov_code}"
end #HXR

# Claim Item Record
def HXT(s)
  svc_code = s[3,5]
  fee_submitted = s[10,6].to_i
  units = s[16,2].to_i
  svc_date = s[18,8].to_date
  diag_code = s[26,6].strip
  expl_code = s[62,2]
  err_code_1 = s[64,3]
  err_code_2 = s[67,3]
  err_code_3 = s[70,3]
  err_code_4 = s[73,3]
  err_code_5 = s[76,3]

   puts "svc_code: #{svc_code}",
	"fee_submitted: #{fee_submitted}",
	"units: #{units}",
	"svc_date: #{svc_date}",
	"diag_code: '#{diag_code}'",
	"expl_code: #{expl_code}",
	"err_code_1: #{err_code_1}",
	"err_code_2: #{err_code_2}",
	"err_code_3: #{err_code_3}",
	"err_code_4: #{err_code_4}",
	"err_code_5: #{err_code_5}"

end # HXT

# Explan Code Message Record (optional)
def HX8(s)
  expl_code = s[3,2]
  expl_descr = s[5,55].strip

   puts "expl_code: #{expl_code}",
	"expl_descr: #{expl_descr}"
end # HX8

# Group/Provider Trailer Record
def HX9(s)
	hxh_count = s[3,7].to_i
	hxr_count = s[10,7].to_i
	hxt_count = s[17,7].to_i
	hx8_count = s[24,7].to_i
  
   puts "hxh_count: #{hxh_count}",
	"hxr_count: #{hxr_count}",
     	"hxt_count: #{hxt_count}",
	"hx8_count: #{hx8_count}"	
end #HX9

files = 0
new_files.each do |f|
#ERROR_FILE = new_files.first

puts "Will do #{f} now:"
content = File.readlines f
content.each do |str| 
  hdr = str[0,3]
  case hdr 
  when 'HX1'
	HX1(str)
  when 'HXH'
	HXH(str)
  when 'HXR'
	HXR(str)
  when 'HXT'
	HXT(str)
  when 'HX8'
	HX8(str)
  when 'HX9'
	HX9(str)
  else
       puts "Invalid header #{hdr} ignored"
  end	  
end

puts "=========================END====================="
files += 1
end

puts "#{files} files processed"
