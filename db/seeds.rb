# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
#
# Load all seed files in ./seeds directory in alphabetical order

require 'csv'
Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each { |seed| load seed  }

# Seed 1 admin and 5 regular users:

User.create( name:  "Meme Me2",
	     email: "me@me2.com",
             password:              "foobar",
             password_confirmation: "foobar",
	     admin: true)

5.times do |n|
  name  = Faker::Name.name
  email = "em-#{n+1}@walkin.com"
  password = "foobar"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end

