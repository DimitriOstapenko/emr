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

