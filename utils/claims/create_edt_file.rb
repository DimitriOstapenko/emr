# Create EDT format file  
# ARG: date, today by default 
#
# verify that service date is before submit date
#

require_relative '../../config/environment'

#datestr = ARGV[0] 
#date = Date.parse(datestr) rescue Date.today

date = Date.new(2018,9,1)  	# we look for visits on this date
puts "Will look for visits on #{date}"

$cre_date_str = Date.today.strftime("%Y%m%d") 
$batch_id = '0635'     # provider agent generated, sequential 1..9999 edt_files.id.to_s[-4,4].rjust(4,'0')
ext =  '003'          		# provider agent generated, sequential 1..31, unique for each submission/doctor during current month
month_letter = 'ABCDEFGHIJKL'[Time.now.month-1]

def hcp_procedure?(proc_code)
  Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
end

def heb_record(v )
  "HEBV03 #{$cre_date_str}#{$batch_id}#{' '*6}#{GROUP_NO}#{v.doctor.provider_no}00".ljust(79,' ') + "\r\n"
end

def heh_record(v, pat)
  "HEH#{pat.ohip_num}#{pat.ohip_ver}#{pat.dob.strftime("%Y%m%d")}#{v.id.to_s.rjust(8,'0')}HCPP".ljust(79,' ') +"\r\n"
end

def het_record(v, s)
  "HET#{s[:pcode]}  #{(s[:fee]*s[:units]*100).to_i.to_s.rjust(6,'0')}#{s[:units].to_s.rjust(2,'0')}#{v.date_str}#{v.diag_code.to_i.to_s.rjust(3,'0')}".ljust(79,' ') + "\r\n"
end

def her_record(pat)
  "HER#{pat.ohip_num.ljust(12,' ')}#{pat.lname[0,9].ljust(9,' ')}#{pat.fname[0,5].ljust(5,' ')}#{DIG_SEXES[pat.sex]}#{pat.hin_prov}".ljust(79,' ') + "\r\n"
end

def hee_record( heh_count, her_count, het_count )
  "HEE#{heh_count.to_s.rjust(4,'0')}#{her_count.to_s.rjust(4,'0')}#{het_count.to_s.rjust(5,'0')}".ljust(79,' ') + "\r\n"
end

def write_file_for_doc( filespec, visits )
      heh_count = het_count = her_count = 0
      begin
      file = File.open(filespec, 'w')
      file.write( heb_record(visits.first) )
      visits.all.each do |v| 
        pat = Patient.find(v.patient_id)
	if v.hcp_services? 
          file.write( heh_record(v,pat) )
	  heh_count += 1
#!!	  v.update_attribute(:status, BILLED) 
	  v.update_attribute(:export_file, filespec.basename) 
	  if v.bil_type == RMB_BILLING  		# only 1 RMB claim supported per visit right now	
	    file.write( her_record(pat) )
	    her_count +=1
	  end
	end
	v.services.each do |svc| 
	  next unless hcp_procedure?(svc[:pcode]) 
	  file.write( het_record(v, svc) )
	  het_count += 1
        end
      end 
      file.write( hee_record(heh_count, her_count, het_count) )
      rescue Errno::ENOENT => e
	  puts e.message.inspect
	  error = 1
      ensure
       file.close 
      end
end

# Generate file content
def generate_file_for_doc( edt_file, visits )
      heh_count = het_count = her_count = 0; body = ''
      body << heb_record(visits.first) 
      visits.all.each do |v| 
        pat = Patient.find(v.patient_id)
	if v.hcp_services? 
          body << heh_record(v,pat) 
	  heh_count += 1
#!!	  v.update_attribute(:status, BILLED) 
	  v.update_attribute(:export_file, edt_file.filename) 
	  if v.bil_type == RMB_BILLING  		# only 1 RMB claim supported per visit right now	
	    body << her_record(pat)
	    her_count +=1
	  end
	end
	v.services.each do |svc| 
	  next unless hcp_procedure?(svc[:pcode]) 
	  body << het_record(v, svc)
	  het_count += 1
        end
      end 
      body << hee_record(heh_count, her_count, het_count) 
      return [body, heh_count]
end

# Which doctors worked on that day?
docs = Visit.where("date(entry_ts)=?", date).group(:doc_id).pluck(:doc_id)
docs.each do |doc_id|
  doc = Doctor.find(doc_id)
  fname = "H#{month_letter}#{doc.provider_no}.#{ext}" 
  filespec = EDT_PATH.join(fname)
  puts "Creating file #{fname} for Dr. #{doc.lname}"
  visits = Visit.where("status=? AND date(entry_ts)=? AND doc_id=?", READY, date, doc_id)
  next unless visits.any?
# write_file_for_doc(filespec,visits)
  edt_file = EdtFile.new(:ftype => EDT_CLAIM, 
			 :filename => fname, 
			 :upload_date => Time.now, 
			 :provider_no => doc.provider_no, 
			 :group_no => GROUP_NO, 
			 :lines => 1,
			 :seq_no => 1 )  
  (edt_file.body, edt_file.claims) = generate_file_for_doc(edt_file,visits)
  if edt_file.save
    puts edt_file.body
  else
    puts edt_file.errors.full_messages.to_sentence
  end
end

