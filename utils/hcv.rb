#curl --location --request POST 'https://api.mdmax.ca/api/1.1/wf/api-validation-call' --header 'Authorization: Bearer 3a213663160927a0335e7f3baf2c8b28' --header 'Cookie: __cfduid=deef3863bc8d33051df1916a9e4dfd571605555555' --form 'Provider-number=015539' --form 'HCN=6728304590' --form 'VC=AG' --form 'User=dimitri'
#{
#    "status": "success",
#    "response": {
#        "First-name": "KIMBERLEY",
#        "Last-name": "THOM",
#        "Gender": "F",
#        "DOB": "3/29/66",
#        "MOH-Duration": 0.690166651,
#        "MOH-card-status": "valid",
#        "MOH-card-eligible": true,
#        "MOH-Message": "Health card passed validation",
#        "MOH-response-code": "50",
#        "MOH-action": "You will receive payment for billable services rendered on this day."
#    }
#}


require "uri"
require "net/http"
require "JSON"

url = URI("https://api.mdmax.ca/api/1.1/wf/api-validation-call")
https = Net::HTTP.new(url.host, url.port);
https.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Authorization"] = "Bearer 3a213663160927a0335e7f3baf2c8b28"
#request["Cookie"] = "__cfduid=deef3c863bc8d33051df1916a9e4dfd571605555555"
#form_data = [['Provider-number', '015539'],['HCN', '6728304590'],['VC', 'AG'],['User', 'dimitri']]
#form_data = [['Provider-number', '015539'],['HCN', '9132049280'],['VC', 'RE'],['User', 'dimitri']]
form_data = [['Provider-number', '015539'],['HCN', '3333333333'],['VC', 'XX'],['User', 'dimitri']]
request.set_form form_data, 'multipart/form-data'
response = https.request(request)
#puts response.read_body

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


