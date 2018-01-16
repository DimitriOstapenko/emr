# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
#
User.create( name:  "Meme Me2",
	     email: "me@me2.com",
             password:              "foobar",
             password_confirmation: "foobar",
	     admin: true)


#99.times do |n|
#  name  = Faker::Name.name
#  email = "example-#{n+1}@railstutorial.org"
#  password = "password"
#  User.create!(name:  name,
#               email: email,
#               password:              password,
#               password_confirmation: password)
#end


# Seed patient table
i=0
59.times do |n|
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

# Seed visits for first 10 patients
#
patients = Patient.order(:created_at).take(10)
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

# Seed doctors table
#
50.times do |n|
  	llname  = Faker::Name.last_name
  	fname  = Faker::Name.first_name
  	cpso = Faker::Number.number(5)
  	billing = Faker::Number.number(6)
	lic = Faker::Number.number(8)
	group_no = Faker::Number.number(4)
        addr = Faker::Address.street_address
        city = Faker::Address.city
        phone  = Faker::PhoneNumber.phone_number
	Doctor.create!(lname: llname,
		       fname: fname,
		       cpso_num: cpso,
		       billing_num: billing,
	 	       service: 'GENP',
		       ph_type: 'GP',
		       district: 'G',
		       bills: true,
		       address: addr,
		       city: city,
		       prov: 'ON',
		       postal: 'L9G1G1',
		       phone: phone,
		       mobile: phone,
		       licence_no: lic.to_s,
		       note: 'empty',
		       office: addr,
		       provider_no: billing,
		       group_no: group_no.to_s,
		       specialty: '00',	
		       email: 'em@email.com'
		      )
end
