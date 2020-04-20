# Nexmo voice call in russian
#

require 'nexmo'
require_relative './config/environment'

client = Nexmo::Client.new(
  application_id: Rails.application.credentials[:nexmo_voice][:application_id],
  private_key: File.read('config/nexmo_voice.key')
)

ncco = [{
  "action": "talk",
  "voiceName": "Tatyana",
  "text": "Здравствуйте доктор Остапенко! К вам только что зарегистрировался пациент."
}]

response = client.voice.create(
  to: [{
    type: 'phone',
    number: '33699436691'
#    number: Rails.application.credentials[:nexmo_voice][:to_number] 
  }],
  from: {
    type: 'phone',
    number: Rails.application.credentials[:nexmo_voice][:from_number]
  },
  ncco: ncco
)

puts(response)
