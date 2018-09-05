#
# Set doc_id field in billings and visits table to match doctor.id 
#

# Next 3 lines allow to run it in stand-alone mode
require_relative '../../config/environment'
require 'date'
require 'csv'
  
puts "About to update visits and billings with doc_id from doctors table"

Doctor.all.each do |d|

  puts "doc: #{d.id}"
  Visit.where(doc_code: d.doc_code).update_all("doc_id = #{d.id}")
  Billing.where(doc_code: d.doc_code).update_all("doc_id = #{d.id}")

end


