#
# Seed billings table (historical billings only)
#

# Next 3 lines allow to run it in stand-alone mode
require_relative '../../config/environment'
require 'date'
require 'csv'

puts "About to seed billings table; validity checks should be on for: pat_id, doc_id, visit_id, proc_code, fee" 

csv_text = File.read(Rails.root.join('lib', 'seeds', 'billing_data.csv'))  # billing_short.csv
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1' ) # .first(10000)

def ts( str, format="%m/%d/%Y %k:%M:%S" )
        DateTime.strptime(str,format) rescue DateTime.new(1900,1,1)
end

#Billing.destroy_all
added = 0

csv.each do |row|
#  puts row.to_hash
  
  bill_id = row['bilid']
  next if Billing.exists?(bill_id)

  pat_id = row['pat_code']
  unless Patient.exists?(pat_id)
    puts "Patient not found: #{pat_id} for bill #{bill_id}" 
    next
  end 

  visit_id = row['ordno']
  visit_date = ts(row['visit_date'], '%m/%d/%Y')
  next if visit_date < Date.today - 1.year

  paid_date = ts(row['paid_date'], '%m/%d/%Y')
  submit_ts = ts(row['submt_date'] +' '+ row['submt_time'])

  billing = Billing.new  id: bill_id,
  			 pat_id: pat_id,
                         doc_code: row['doc_code'],
			 visit_date: visit_date,
			 visit_id: visit_id,
			 proc_code: row['proc_code'],
			 proc_units: row['proc_count'],
			 fee: row['fee'],
			 btype: row['type'],
			 diag_code: row['diagnosis'],
			 status: row['status'],
			 amt_paid: row['amt_paid'],
			 paid_date: paid_date, 
			 write_off: row['write_off'],
			 submit_file: row['submt_file'],
			 submit_year: row['submt_year'],
			 remit_file: row['remit_file'],
			 remit_year: row['remit_year'],
			 mohref: row['mohrefno'], 
			 bill_prov: row['bill_prov'],
			 submit_user: row['submt_user'],
			 submit_ts: submit_ts

  if billing.save(validate: false)
     puts "*** #{bill_id}  saved"
     added += 1
  else
     puts "Problem billing: #{bill_id}"
     puts billing.errors.full_messages
  end

end

puts "Now #{Billing.count} records in billings table. Added #{added} records "


#{"hst"=>"0.00", "pat_code"=>"130", "doc_code"=>"l&", "loc_code"=>"", "visit_date"=>"01/26/2006", "ordno"=>"122", "claim_type"=>" ", "claim"=>"94", "proc_code"=>"A007A", "proc_count"=>"1.00", "fee"=>"29.70", "diagnosis"=>"917.0", "ref_phys"=>"", "type"=>"HCP", "status"=>"PAID BY MOH", "facilno"=>"", "adm_date"=>"/  /", "man_review"=>"F", "amt_paid"=>"29.70", "paid_date"=>"03/14/2006", "entry_date"=>"01/26/2006", "shadow"=>"F", "write_off"=>"0.00", "surg2"=>"F", "category"=>" ", "subcateg"=>" ", "bilid"=>"1124", "entry_by"=>"HS", "office"=>" ", "submt_file"=>"HA015539.001", "submt_year"=>"2006", "remit_file"=>"PC015539.735", "remit_year"=>"2006", "rma_locn"=>"", "rma_confid"=>"F", "batch_id"=>"", "bill_patid"=>"0", "bill_btoid"=>"0", "locn_type"=>" ", "entry_time"=>"19:49:57", "mod_date"=>"/  /", "mod_time"=>"", "mod_by"=>"", "mohrefno"=>"G6020258370", "last_date"=>"/  /", "after_hrs"=>" ", "seq_no"=>"0", "incl_notes"=>"F", "tech_flag"=>"F", "inter_flag"=>"F", "serv_clas"=>"", "bill_prov"=>"ON", "submt_user"=>"HS", "submt_date"=>"01/30/2006", "submt_time"=>"16:43:45", "paid_user"=>"HS", "paid_time"=>"13:09:39", "gst"=>"0.00", "pst"=>"0.00", "ohip_sli"=>"", "bilateral"=>"", "pc_rate"=>"0.00", "ineligible"=>"F", "overridden"=>"F", "overrid_by"=>"", "overrid_dt"=>"/  /", "overrid_tm"=>"", "serv_type"=>" ", "visit_time"=>"", "ramq"=>"F", "modifier"=>"", "special"=>"", "accid_date"=>"/  /", "alt_ref_no"=>""}






