#
# Set doc_id field in billings and visits table to match doctor.id 
#

# need next line if run stand-alone
 require_relative '../../config/environment'

  
Doctor.all.each do |d|

  puts d.id
  Visit.where(doc_code: d.doc_code).update_all("doc_id = #{d.id}")
  Billing.where(doc_code: d.doc_code).update_all("doc_id = #{d.id}")

end


