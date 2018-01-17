#
# Seed patient table
#

i=0
50.times do |n|
  i = (i>9) ? 1 : i+1
  lname  = Faker::Name.last_name
  fname  = Faker::Name.first_name
  ohip_num = Faker::Number.number(10)
  dob =  Faker::Date.birthday(min_age = 18, max_age = 65)
  phone  = Faker::PhoneNumber.phone_number
  addr = Faker::Address.street_address
  city = Faker::Address.city
  country = Faker::Address.country
  Patient.create!(lname:  lname,
                  fname:  fname,
                  sex: 'M',
                  ohip_num: ohip_num,
                  dob: dob,
                  last_visit_date: Date.today - rand(3),
                  phone: phone,
                  addr: addr,
                  city: city,
                  prov: 'ON',
                  postal: 'L9G1G1',
                  country: country
                 )
end

# Seed visits for first 10 patients alphabetically
#
patients = Patient.order(:lname).take(10)
50.times do
  notes = Faker::Lorem.sentence(5)
  diag_code = Faker::Number.number(6)
  proc_code = 'A09'
  patients.each { |patient| patient.visits.create!(notes: notes,
                                                 diag_code: diag_code,
                                                 proc_code: proc_code,
                                                 doc_id: 1
                                                ) }
end

