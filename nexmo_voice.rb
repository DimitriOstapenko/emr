# Nexmo voice call in russian
#

require 'nexmo'
require_relative './config/environment'

#puts Rails.application.credentials[:nexmo_voice][:private_key]
#  application_id: "3d2ee3fc-b750-4a17-9bb5-e2a7fa716012",
#  private_key: File.read(Rails.root.join(Rails.application.credentials[:nexmo_voice][:private_key]))

client = Nexmo::Client.new(
  application_id: Rails.application.credentials[:nexmo_voice][:application_id],
  private_key: File.read('nexmo_voice.key')
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
