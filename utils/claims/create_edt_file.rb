# Create EdtFile object and save into DB
# ARG: [date],  All ready claims by default
#
# - One file for doctor is generated
# - Whole batch is ignored if total for it is close to last file's total and number of lines is the same
#

require_relative '../../config/environment'
include My::EDT

month_letter = 'ABCDEFGHIJKL'[Time.now.month-1]
puts "Will look for all ready to bill visits" 

# Is procedure insured? (present in application_controller)
def hcp_procedure?(proc_code)
  Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
end

# Which doctors worked on that day?
docs = Visit.where("status=?", READY).reorder('').group(:doc_id).pluck(:doc_id)
docs.each do |doc_id|
  doc = Doctor.find(doc_id)
  last_seq_no = 0; last_ttl_amt = 0.0; 

# Construct output file name  
  basename = "H#{month_letter}#{doc.provider_no}"

# But first find latest file's seq_no for this doctor 
  last_seq_no = EdtFile.where('filename like ?', "#{basename}.%").order(seq_no: :desc).limit(1).pluck(:seq_no).first || 0
  seq_no = last_seq_no + 1
  ext = seq_no.to_s.rjust(3,'0')
  last_ext = last_seq_no.to_s.rjust(3,'0')
  filename = "#{basename}.#{ext}" 
  filespec = EDT_PATH.join(filename)
  visits = Visit.where("status=? AND doc_id=?", READY, doc_id) 
  next unless visits.any?
  puts "Got #{visits.count} visits to export"

# Create empty edt_file object to get the id of new record  
  edt_file = EdtFile.new
  abort "could not create new record in edt_files table" unless edt_file.save(validate: false)
  puts "Will create EDT claim #{filename} for Dr. #{doc.lname}"

  (body, claims, svcs, ttl_amt) = generate_claim_for_doc(edt_file.id,filename,visits)

  if edt_file.update_attributes(ftype: EDT_CLAIM, 
			      filename: filename, 
			      upload_date: Time.now, 
			      provider_no: doc.provider_no, 
			      group_no: GROUP_NO, 
			      body: body,
			      lines: body.lines.count,
			      claims: claims,
			      services: svcs,
			      total_amount: ttl_amt,
			      seq_no: seq_no ) 
    puts edt_file.body
    edt_file.write
  else
    puts "Couldn't save "+  edt_file.errors.full_messages.to_sentence
    edt_file.destroy
  end
end

