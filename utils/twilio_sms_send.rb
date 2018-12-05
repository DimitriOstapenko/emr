# Download the twilio-ruby library from twilio.com/docs/libraries/ruby
require 'twilio-ruby'

account_sid = 'ACa1e2a4a3a1d5475607aa85eaf192f4a5'
auth_token = '4d295b397e572aa785804c4c3e2f2174'
client = Twilio::REST::Client.new(account_sid, auth_token)

from = '+16475593960' # Your Twilio number
to = '+19053043921' # Your mobile phone number

client.messages.create(
from: from,
to: to,
body: "Hey friend!"
)
