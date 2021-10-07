#curl --location --request POST 'https://api.mdmax.ca/api/1.1/wf/api-validation-call-testing-v3' \
#--header 'Authorization: Bearer eae0c0f2f6446408a900f31a9af201dd' \
#--form 'provider-number="123456"' \
#--form 'hcn="1234567890"' \
#--form 'vc="AA"' \
#--form 'user="dimitri"' \
#--form 'mcedt-email="dosta@me.com"' \
#--form 'mcedt-pass="Kwartira39@@"'

#{
#    "status": "success",
#    "response": {
#        "First-name": "Justin",
#        "Last-name": "Trudeau",
#        "Gender": "M",
#        "DOB": "1979-01-21",
#        "MOH-Duration": 1,
#        "MOH-card-status": "valid",
#        "MOH-card-eligible": true,
#        "MOH-Message": "You will receive payment for billable services rendered on this day.",
#        "MOH-response-code": "50",
#        "MOH-action": "NOT_ON_ACTIVE_ROSTER"
#    }


require_relative '../config/environment'
require "uri"
require "net/http"
#require "JSON"

# Testing url:
#url = URI("https://api.mdmax.ca/api/1.1/wf/api-validation-call-testing-v3")
# Live url
url = URI("https://api.mdmax.ca/api/1.1/wf/api-validation-call-v3")

https = Net::HTTP.new(url.host, url.port);
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Authorization"] = MDMAX_BEARER
form_data = [['provider-number', MDMAX_PROVIDER_NUMBER],['hcn', '6136304950'],['vc', 'TD'],['user', MDMAX_USER],['mcedt-email', GO_EMAIL], ['mcedt-pass', GO_PASS]]
request.set_form form_data, 'multipart/form-data'
response = https.request(request)
puts response.read_body

exit
puts "request status: #{response.message}"
json = JSON.parse(response.body)
status = json['status']
response = json['response']

puts "json status: #{status}"
puts "fname: #{response['First-name']}"
puts "lname: #{response['Last-name']}"
puts "gender: #{response['Gender']}"
puts "dob: #{response['DOB']}"
puts "moh status: #{response['MOH-card-status']}"
puts "message: #{response['MOH-Message']}"
puts "eligible? #{response['MOH-card-eligible']}"

eligible = response['MOH-card-eligible'] == true

puts 'Card is eligible' if eligible


