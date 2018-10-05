# Find and process new batch files in EDT directory  
#
#  ARGV: target month's letter, optional. If none given, current month will be used
#
# Files like: BA00001.123  (Jan) in EDT
#
# Ignore already processed files
#
require_relative '../../config/environment'
require 'date'

abort "EDT directory does not exist." unless File.directory?(EDT_PATH)

this_month = Date.today.month
this_month_name = Date.today.strftime("%B")
this_month_letter = ARGV[0] || THIS_MONTH_LETTER
puts this_month_letter 
path = EDT_PATH.join("B#{this_month_letter.upcase}*.*")
new_files = Dir.glob(path)

puts new_files.inspect

abort "File not found: #{path}" unless new_files.any?

# 
def HB1(s) 
   batch_no = s[6,5]
   oper_no = s[11,6]
   cre_date = s[17,8]
   seq_no =s[25,4]
   micro_start = s[29,11]
   micro_end = s[40,5]
   micro_type = s[45,7]
   group_no = s[52,4]
   provider_no = s[56,6]
   no_of_claims = s[62,5]
   no_of_records = s[67,6]
   proc_date = s[73,8]
   edit_msg = s[81,40]
   moh_use_msg = s[121,11]

   puts "batch_no: #{batch_no}", 
	"oper_no: #{oper_no}", 
	"cre_date: #{cre_date.to_date}", 
	"seq_no: #{seq_no}", 
	"micro_start: #{micro_start}",
	"micro_end: #{micro_end}", 
	"micro_type: #{micro_type}", 
	"group_no: #{group_no}", 
	"provider_no: #{provider_no}", 
	"no_of_claims: #{no_of_claims}", 
	"no_of_records: #{no_of_records}", 
	"proc_date: #{proc_date.to_date}", 
	"edit_msg: #{edit_msg}", 
	"moh_use_msg: #{moh_use_msg}"
end

BATCH_FILE = new_files.first

content = File.readlines BATCH_FILE
content.each do |str| 
  hdr = str[0,3]
  case hdr 
  when 'HB1'
	HB1(str)
  else
  end	  
end

