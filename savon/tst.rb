require "savon"
require_relative '../config/environment'

#realm = Base64.strict_encode64("confsu339@outlook.com:Password1!")
client = Savon.client( log_level: :debug,
		       log: true,
		     #  ssl_verify_mode: :none,
		       ssl_cert_file: "/Users/dmitri/rstuff/walkin/savon/cert/L1K.cer",
		       ssl_cert_key_file: "/Users/dmitri/.ssh/id_rsa",
		       wsdl: "https://ws.conf.ebs.health.gov.on.ca:1444/HCVService/HCValidationService?wsdl",
#		       headers: { 'Authorization' => "Basic #{realm}"},
		       pretty_print_xml: true
#		       logger: Rails.logger
		     )


#resp = client.call(:validate) do |soap|
#      soap.namespaces["xmlns:hcv"] = "urn:http://hcv.health.ontario.ca/"
#      soap.header = { "wsdl:Credentials" => {
#        "UserName" => 'onfsu339@outlook.com', "Password" => 'Password1!' } }
#      soap.body = { hcvRequest: {"healthNumber" => "1286844022", "versionCode" => "YZ"} } 
#    end

response = client.call(:validate, message: {"healthNumber" => "1286844022", "versionCode" => "YZ"},
		       :soap_header => { "UserName" => "onfsu339@outlook.com", "Password" => "Password1!", 
			SoftwareConformanceKey: "c58b5dfa-8aac-48e3-9467-195370360de7" })

#response =  client.call(:validate, hcvRequest: {"healthNumber" => '1286844022', "versionCode" => 'YZ'} )
#puts response.inspect
#
puts response.inspect

