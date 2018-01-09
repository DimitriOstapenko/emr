# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
#
User.create(name:  "Meme Me2",
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


i=0
559.times do |n|
  i = (i>9) ? 1 : i+1 
  lname  = Faker::Name.last_name
  fname  = Faker::Name.first_name
  ohip_num = Faker::Number.number(10)
  dob =  Faker::Date.birthday(min_age = 18, max_age = 65) 
  phone  = Faker::PhoneNumber.phone_number
  Patient.create!(lname:  lname,
		  fname:  fname, 
		  sex: 1,
		  ohip_num: ohip_num,
		  dob: dob,
		  phone: phone)

end

patients = Patient.order(:created_at).take(10)
50.times do
  notes = Faker::Lorem.sentence(5)
  date = Faker::Date.birthday(min_age = 0, max_age = 2)
  diag_code = Faker::Number.number(6)
  proc_code = 'A09'
  patients.each { |patient| patient.visits.create!(notes: notes,
						 date: date,
						 diag_code: diag_code,
						 proc_code: proc_code
						) }

end

