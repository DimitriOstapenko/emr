require 'faker'
require_relative '../../config/environment'

#
# Seed claims
#
#Claim:
#    t.string "claim_no"
#    t.string "provider_no"
#    t.string "accounting_no"
#    t.string "pat_lname"
#    t.string "pat_fname"
#    t.string "province"
#    t.string "ohip_num"
#    t.string "ohip_ver"
#    t.string "pmt_pgm"
#    t.string "moh_group_id"
#    t.integer "visit_id"
#    t.string "ra_file"
#    t.date "date_paid"
#
#Service:
#    t.string "claim_no"
#    t.integer "tr_type"
#    t.date "svc_date"
#    t.integer "units"
#    t.string "svc_code"
#    t.integer "amt_subm"
#    t.integer "amt_paid"
#    t.string "errcode"
#    t.integer "claim_id"

def rand_char
	('A'..'Z').to_a[rand(26)]
end

50.times do 
  claim_no  = 'G'+Faker::Number::number(10).to_s
  provider_no  = '015539'
  accounting_no = Faker::Number::hexadecimal(8).upcase
  ohip_num =  Faker::Number::number(10)
  ohip_ver =  rand_char+rand_char
  visit_id = rand(1..Visit.all.count) 
  ra_file = 'RA_Filespec.txt'
  
  Claim.create!(  claim_no: claim_no,
                  provider_no:  provider_no,
                  accounting_no: accounting_no,
		  province: 'ON',
                  ohip_num: ohip_num,
                  ohip_ver: ohip_ver,
		  pmt_pgm: 'HCP',
		  moh_group_id: '0078',
		  visit_id: visit_id,
		  ra_file: ra_file,
		  date_paid: Date.today
               )
end

puts "#{Claim.count} fake claims added to claims table "

# Seed services for all claims 
Claim.all.each do |claim|
  diag_code = Faker::Number.number(3)
  date = Faker::Date.backward(rand(60))
  amt = [3370, 1550, 3705]
  svcs  = rand(1..3)
  (1..svcs).each do |service|
		  claim.services.create!(tr_type: rand(1..3),  
			  claim_no: claim.claim_no,
			  svc_date: date, 
                          units: 1, 
			  svc_code: 'A00'+rand(9).to_s+'A',
			  amt_subm: amt[rand(2)],
			  amt_paid: amt[rand(2)]
                          )
  end
end

puts "#{Service.count} fake services created"
