# Send SMS message to a phone
require 'nexmo'
require_relative './config/environment'

NEXMO_API_KEY = Rails.application.credentials[:nexmo_sms][:api_key] 
NEXMO_API_SECRET =  Rails.application.credentials[:nexmo_sms][:api_secret] 

TO_NUMBER = "33699436691"
# TO_NUMBER =  Rails.application.credentials[:nexmo_voice][:to_number] 

client = Nexmo::Client.new(
  api_key: NEXMO_API_KEY,
  api_secret: NEXMO_API_SECRET
)

client.sms.send(
  from: 'Walk-In EMR',
  to: TO_NUMBER,
  text: 'A text message sent using the Nexmo SMS API'
)
