
require_relative './config/environment'
require 'nexmo'

client = Nexmo::Client.new(
  application_id: Rails.application.credentials[:nexmo_voice][:application_id],
#  application_id: '3d2ee3fc-b750-4a17-9bb5-e2a7fa716012',
  private_key: File.read("nexmo_voice.key")
)

ncco = [{
  "action": "talk",
  "voiceName": "Tatyana",
  "text": "Привет!"
}]

response = client.calls.create(
  to: [{
    type: 'phone',
    number: '33699436691'
  }],
  from: {
    type: 'phone',
    number: '33699436691'
  },
  ncco: ncco
)

puts(response)
