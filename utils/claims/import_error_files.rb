# Import error files into edt_files table; 
# ignore already imported files
# 
#  ARGV: Month Letter, current month by default
#  Files like: EA0078.504  (Jan) in EDT
#
# For each file:
#   - find visit with billing_ref matching accounting_no
#     - set status to error
#     - set billing_ref to error(s)
#
require_relative '../../config/environment'

abort "EDT directory does not exist." unless File.directory?(EDT_PATH)

this_month_name = Date.today.strftime("%B")
this_month_letter = ARGV[0] || THIS_MONTH_LETTER
puts "will look for #{this_month_letter} files"
path = EDT_PATH.join("E#{this_month_letter.upcase}*.*")
new_files = Dir.glob(path)
abort "No files found matching #{path}" unless new_files.any?

puts "found #{new_files.count} files for given month"
files = 0

class ErrorFile
  attr_reader :name, :ftype, :claims, :hcp_svcs, :rmb_svcs, :services, :total_amount,
	      :body, :doctors, :group_no, :upload_date, :seq_no, :visit, :updated
  def initialize(filename)
    @name = File.basename(filename)
    @body = File.readlines(filename, chomp: true) rescue []
    n,ext = @name.split('.')
    @seq_no = ext.to_i
    @claims = @services = @hcp_svcs = @rmb_svcs = 0
    @total_amount = 0.0
    @doctors = {}
    @ftype = EDT_ERROR
    @visit = nil            # last visit processed
    @updated = 0            # updated visits number
  end

# Group/Provider Header Record 
def HX1(s)
   provider_no = s[27,6]
   @group_no = s[23,4]
   claim_proc_date = s[38,8].to_date
   @upload_date = claim_proc_date 	# we will just use the date of the last error in a batch
   @doctors[provider_no] = 1            # In case there's more than one section per doctor
end  

# Claims Header 1 Record
def HXH(s)
  health_no = s[3,10].to_i
  version_code = s[13,2]
  pat_dob = s[15,8].to_date
  accounting_no = s[23,8].strip
  @visit = Visit.find_by(billing_ref: accounting_no)
end

# Claims Header 2 Record (RMB claims only)
def HXR(s)
  reg_no = s[3,12] # HN for different provinces ranges from 8 to 12 chars
  pat_last_name = s[15,9].strip
  pat_first_name = s[24,5].strip
  pat_sex = s[29,1]
  prov_code = s[30,2]
end 

# Claim Item Record
def HXT(s)
  fee_submitted = s[10,6].to_i/100.0
  svc_date = s[18,8].to_date
  err = []
  err[0] = s[64,3]
  err[1] = s[67,3]
  err[2] = s[70,3]
  err[3] = s[73,3]

  if @visit.present?
     @visit.update_attributes(status: ERROR, billing_ref: err.reject(&:blank?).join(','))
     @updated += 1
  end
  @total_amount += fee_submitted  # rejected amount
end

# Group/Provider Trailer Record
def HX9(s)
  hxh_count = s[3,7].to_i
  hxr_count = s[10,7].to_i
  hxt_count = s[17,7].to_i
  @claims += hxh_count
  @hcp_svcs += hxt_count
  @rmb_svcs += hxr_count
  @services += hxt_count + hxr_count
end #HX9
end #class

new_files.each do |f|
  puts "Will process #{f}:"
  file = ErrorFile.new(f)
  if EdtFile.exists?(filename: file.name)
    puts "File was already imported"
    next
  end

  file.body.each do |str| 
    hdr = str[0,3]
    case hdr 
      when 'HX1'
        file.HX1(str)
      when 'HXH'
        file.HXH(str)
      when 'HXR'
        file.HXR(str)
      when 'HXT'
        file.HXT(str)
      when 'HX9'
        file.HX9(str)
    end	  
  end

  EdtFile.create!(ftype: file.ftype,
	       filename: file.name, 
	       upload_date: file.upload_date, 
	       provider_no: 0, 
	       group_no: file.group_no, 
	       doctors: file.doctors.keys.size,
	       body: file.body.join("\n"),
	       lines: file.body.size, 
	       claims: file.claims, 
	       hcp_svcs: file.hcp_svcs,
	       rmb_svcs: file.rmb_svcs,
	       services: file.hcp_svcs + file.rmb_svcs, 
	       total_amount: file.total_amount,
	       seq_no: file.seq_no,
	       processed: true )
  files += 1
  puts "updated #{file.updated} visits for this file"
end

puts "Processed #{files} files"




