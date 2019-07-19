# Process batch files
#
# - Get all batch files in EDT directory
# - For each, if it wasn't processed:
#   - find corresponding claim file and mark it as processed if no errors 
#   - Import batch into edt_files table
#   - Mark batch as processed
#   - delete file from directory

require_relative '../../config/environment'

abort "EDT directory does not exist." unless File.directory?(EDT_PATH)

puts "will look for B*.* files in EDT"
path = EDT_PATH.join("B*.*")
new_files = Dir.glob(path)
abort "No files found matching #{path}" unless new_files.any?

puts "found #{new_files.count} batch files in EDT directory"

class BatchFile
  attr_reader :filespec, :name, :ftype, :batch_num, :batch_id, :operator_num, :batch_credate, :micro_start, :micro_end, :micro_type,
	      :hcp_svcs, :rmb_svcs, :ttl_svcs, :records, :body, :provider_no, :group_no, :batch_credate, :batch_process_date, 
	      :edit_msg, :seq_no, :reject_flag, :accepted

	def initialize(filename)
	    @filespec = filename
	    @name = File.basename(filename)
	    @body = File.readlines(filename, chomp: true) rescue []
	    n,ext = @name.split('.')
	    @seq_no = ext.to_i
	    @records = @provider_no = @group_no = @operator_num = @rmb_svcs = @hcp_svcs = @ttl_svcs =  0
	    @ftype = EDT_BATCH
	    @accepted = false
	end

	def parse_line(s)
	abort "not a batch file" unless s[0,3] = 'HB1'

	@batch_num = s[6,5]	    		 # Ministry assigned
	@operator_num = s[11,6]      		 # seems to be always '000000'
	@batch_credate = s[17,8].to_date         # submit date
	@batch_id = s[25,4].to_i    		 # this is id that links to claim file (H*.*), appears in header line [15,4] (edt_file.id)
	@micro_start = s[29,11]                  # OHIP claim number - first claim
	@micro_end = s[40,5]
	@micro_type = s[45,7]		         # HCP/WCB or RMB
	@group_no = s[52,4]
	@provider_no = s[56,6]
	if @micro_type.match('HCP')
	  @hcp_svcs = s[62,5].to_i
	elsif @micro_type.match('RMB')
	  @rmb_svcs = s[62,5].to_i
	end
	@ttl_svcs = @hcp_svcs + @rmb_svcs
	@number_of_records = s[67,6].to_i 	# Records in H claim file
	@batch_process_date =s[73,8].to_date
	@edit_msg = s[81,40]
	@reject_flag = s[39,1] == 'R'
	@accepted = @edit_msg.match?('BATCH TOTALS')

#	puts "batch_num #{@batch_num}"
#	puts "operator_num #{@operator_num}"
#	puts "batch_credate #{@batch_credate}" 
	puts "batch_id #{@batch_id}" 
#	puts "micro_start #{@micro_start}"
#	puts "micro_end #{@micro_end}"
#	puts "micro_type #{@micro_type}" 
#	puts "group_no #{@group_no}"
	puts "provider_no #{@provider_no}"
	puts "hcp_svcs: #{@hcp_svcs}; rbm_svcs: #{@rmb_svcs}; ttl_svcs: #{@ttl_svcs}"
	puts "number_of_records #{@number_of_records}"
	puts "batch_process_date #{@batch_process_date}"
#	puts "edit_msg #{@edit_msg}"
#	puts "reject_flag: #{@reject_flag}"
	puts "accepted: #{@accepted}"

	end # parse_line

	def Save
	  EdtFile.create!(ftype: @ftype,
		       filename: @name, 
		       upload_date: @batch_credate, 
		       provider_no: @provider_no,   # last doctor's in the file
		       group_no: @group_no, 
		       doctors: 1, 
		       body: @body.join("\n"),
		       lines: @body.size, 
		       claims: @ttl_svcs, 
		       hcp_svcs: @hcp_svcs,
		       rmb_svcs: @rmb_svcs,
		       services: @ttl_svcs,
		       total_amount: 0,
		       seq_no: @seq_no, # Batch sequence, or id in H claim, not file extension
		       batch_id: @batch_id,
		       processed: true ) 
	end
end # class

processed_files = 0
new_files.each do |f|
  puts "Will process #{File.basename(f)}:"
  batch_file = BatchFile.new(f)
# 1 line for WCB/RMB, 1 line for RMB, 1 line for totals in all files without errors
  batch_file.body.each do |str|  
    batch_file.parse_line(str)
  end  

# Find corresponding claim file and set "processed" attr to true if micro_start present 
  claim_file = EdtFile.find(batch_file.batch_id) rescue nil
  if claim_file.present? 
     if claim_file.processed? # processed claim is the one accepted by MHO
  	puts "** Claim #{claim_file.filename} was already processed"
	File.delete( batch_file.filespec ) rescue nil
	next
     else
	puts "** Claim file found for this batch: #{claim_file.filename}"
	if batch_file.accepted
	  puts "** Claim is accepted as valid; Setting attributes and saving batch"
	  claim_file.processed = true
	  claim_file.save
	  batch_file.Save unless EdtFile.exists?(filename: batch_file.name)
          processed_files += 1
	  File.delete( batch_file.filespec ) rescue nil
	else 
	  puts "** Claim file present, but was not accepted. No changes made"
	end
	puts
     end		
  else
     puts "** No claim found for this batch - batch ignored \n\n"
  end
end # new_files

puts "Processed #{processed_files} files"





