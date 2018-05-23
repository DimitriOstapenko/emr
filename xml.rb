
def make_post_req

require 'net/http'
require "uri"
#require 'openssl'

uri = URI.parse("https://api.cab.md/claims?apiKey=e679b103-f74d-4b2d-bb60-5f05ad4f9de1")
#uri = URI.parse("https://api.cab.md/test/claims?apiKey=8b912b08-e692-4ac6-9da1-5723199bc666")
http= Net::HTTP.new(uri.host,uri.port)
http.use_ssl = true
#http.verify_mode = OpenSSL::SSL::VERIFY_NONE

req = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/xml'})

#<?xml version="1.0" encoding="UTF-8"?>
req.body=%{
<Claim>
<careProvider>
<groupNumber>0078</groupNumber>
<providerNumber>022337</providerNumber>
</careProvider>
<diagnosticCode>896</diagnosticCode>
<patient>
<firstName>ELENA</firstName>
<lastName>OSTAPENKO</lastName>
<gender>Female</gender>
<dateOfBirth>1961-05-10T00:00:00</dateOfBirth>
<healthCard>6589761847</healthCard>
<versionCode>NK</versionCode>
<provinceCode>ON</provinceCode>
</patient>
<serviceDate>2017-08-08T14:13:15</serviceDate>
<services>
<service>
<serviceCode>A001A</serviceCode>
<quantity>1</quantity>
</service>
<service>
<serviceCode>G847A</serviceCode>
<quantity>1</quantity>
</service>
</services>
<reference_id>313951</reference_id>
</Claim>
}

puts req.inspect

res = http.request(req)
puts "response: #{res.body}"

rescue => e
	puts "failed:  #{e}"

# <reference_id>332929</reference_id>
#res.inspect

#hash = Hash.from_xml(xml)
#puts hash
end

make_post_req
