# Send SMS message to a phone
require 'nexmo'

#NEXMO_API_KEY = ENV['NEXMO_API_KEY']
NEXMO_API_KEY = '370954b9'
#NEXMO_API_SECRET = ENV['NEXMO_API_SECRET']
NEXMO_API_SECRET = '157259c74bc4099b'
#TO_NUMBER = ENV['TO_NUMBER']
TO_NUMBER = "33699436691"

client = Nexmo::Client.new(
  api_key: NEXMO_API_KEY,
  api_secret: NEXMO_API_SECRET
)

client.sms.send(
  from: 'Vonage SMS API',
  to: TO_NUMBER,
  text: 'A text message sent using the Nexmo SMS API'
)
