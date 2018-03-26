require "savon"

realm = Base64.strict_encode64("confsu339@outlook.com:Password1!")
u = Base64.strict_encode64("confsu339@outlook.com")
p = Base64.strict_encode64("Password1!")
client = Savon.client( log_level: :debug,
		       log: true,
		       ssl_verify_mode: :none,
		       ssl_cert_file: "/Users/dmitri/rstuff/walkin/savon/cert/L1K.cer",
		       wsdl: "https://ws.conf.ebs.health.gov.on.ca:1444/HCVService/HCValidationService?wsdl",
		       headers: { 'Authorization' => "Basic #{realm}"},
		       pretty_print_xml: true,
		       logger: Rails.logger
		     )

response =  client.call(:validate, message: {"healthNumber" => '1286844022', "versionCode" => 'YZ',  username: u, password: p} )
#puts response.inspect
#
client.inspect

