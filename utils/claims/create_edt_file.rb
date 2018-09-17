# Create EdtFile object and save into DB
# ARG: [date],  All ready claims by default
#
# - One file for doctor is generated
# - Whole batch is ignored if total for it is close to last file's total and number of lines is the same
#

require_relative '../../config/environment'

month_letter = 'ABCDEFGHIJKL'[Time.now.month-1]
puts "Will look for all ready to bill visits" 

# Is procedure insured?
def hcp_procedure?(proc_code)
  Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
end

# edt_id: id of new empty edt record; v: first visit in a batch
def heb_record( edt_id, v )
  cre_date = Date.today.strftime("%Y%m%d")
  batch_id = edt_id.to_s.rjust(4,'0')
  "HEBV03 #{cre_date}#{batch_id}#{' '*6}#{GROUP_NO}#{v.doctor.provider_no}00".ljust(79,' ') + "\r\n"
end

def heh_record(v, pat)
  if pat.pat_type == RMB_PATIENT
    "HEH#{' '*12}#{pat.dob.strftime("%Y%m%d")}#{v.id.to_s.rjust(8,'0')}RMBP".ljust(79,' ') +"\r\n"
  else
    "HEH#{pat.ohip_num}#{pat.ohip_ver}#{pat.dob.strftime("%Y%m%d")}#{v.id.to_s.rjust(8,'0')}HCPP".ljust(79,' ') +"\r\n"
  end
end

def het_record(v, s)
  "HET#{s[:pcode]}  #{(s[:fee]*s[:units]*100).to_i.to_s.rjust(6,'0')}#{s[:units].to_s.rjust(2,'0')}#{v.date_str}#{v.diag_code.to_i.to_s.rjust(3,'0')}".ljust(79,' ') + "\r\n"
end

def her_record(pat)
  "HER#{pat.ohip_num.ljust(12,' ')}#{pat.lname[0,9].ljust(9,' ')}#{pat.fname[0,5].ljust(5,' ')}#{DIGSEXES[pat.sex]}#{pat.hin_prov}".ljust(79,' ') + "\r\n"
end

def hee_record( heh_count, her_count, het_count )
  "HEE#{heh_count.to_s.rjust(4,'0')}#{her_count.to_s.rjust(4,'0')}#{het_count.to_s.rjust(5,'0')}".ljust(79,' ') + "\r\n"
end

# Generate file content
def generate_claim_for_doc( edt_id, filename, visits )
      claims_count = rmb_count = hcp_count = ttl_fee = 0; body = ''
      body << heb_record(edt_id, visits.first) 
      visits.all.each do |v| 
        pat = Patient.find(v.patient_id)
	ttl_fee += v.total_insured_fees
	if v.hcp_services? 
          body << heh_record(v,pat) 
	  claims_count += 1
#!!	  v.update_attribute(:status, BILLED) 
	  v.update_attribute(:export_file, filename) 
	  if v.bil_type == RMB_BILLING  		# only 1 RMB claim supported per visit right now	
	    body << her_record(pat)
	    rmb_count += 1
	  end
	end
	v.services.each do |svc| 
	  next unless hcp_procedure?(svc[:pcode]) 
	  body << het_record(v, svc)
	  hcp_count += 1
        end
      end 
      body << hee_record(claims_count, rmb_count, hcp_count) 
      return [body, claims_count, ttl_fee]
end

# Which doctors worked on that day?
docs = Visit.where("status=?", READY).reorder('').group(:doc_id).pluck(:doc_id)
docs.each do |doc_id|
  doc = Doctor.find(doc_id)
  last_seq_no = 0; last_ttl_amt = 0.0; last_body = ''

# Construct output file name  
  basename = "H#{month_letter}#{doc.provider_no}"

# But first find latest file's seq_no for this doctor to make sure it wasn't imported already
  row = EdtFile.where('filename like ?', "#{basename}.%").order(seq_no: :desc).limit(1).pluck(:seq_no,:total_amount,:body).first || []
  (last_seq_no,last_ttl_amt,last_body) = row if row.any?
  seq_no = last_seq_no + 1
  ext = seq_no.to_s.rjust(3,'0')
  last_ext = last_seq_no.to_s.rjust(3,'0')
  filename = "#{basename}.#{ext}" 
  filespec = EDT_PATH.join(filename)

# Create empty edt_file object to get the id of new record  
  edt_file = EdtFile.new
  abort "could not create new record in edt_files table" unless edt_file.save(validate: false)
  puts "Will create EDT claim #{filename} for Dr. #{doc.lname} (if not there already)"

# This should be without date when testing is done  
  visits = Visit.where("status=? AND doc_id=?", READY, doc_id) 
  puts "Got #{visits.count} visits to export"
  if !visits.any?
      edt_file.destroy
      next
  end
  
  (body, claims, ttl_amt) = generate_claim_for_doc(edt_file.id,filename,visits)

# Based on total amount decide if batch was already processed  
  if (last_ttl_amt - ttl_amt) && body.lines.count == last_body.lines.count
      puts "This batch was already processed and imported into DB as #{basename}.#{last_ext} - ignoring" 
      edt_file.destroy
      next
  end

  if edt_file.update_attributes(ftype: EDT_CLAIM, 
			      filename: filename, 
			      upload_date: Time.now, 
			      provider_no: doc.provider_no, 
			      group_no: GROUP_NO, 
			      body: body,
			      lines: body.lines.count,
			      claims: claims,
			      total_amount: ttl_amt,
			      seq_no: seq_no ) 
    puts edt_file.body
    edt_file.write
  else
    puts "Couldn't save "+  edt_file.errors.full_messages.to_sentence
    edt_file.destroy
  end
end

