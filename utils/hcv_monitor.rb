# Monitor HCV service, send alerts if down
# runs from cron every now and then (5min?)
#

require_relative '../config/environment'

patient = Patient.first
response = patient.get_hcv_response
json = JSON.parse(response.body)
hcv = (SvcMonitor.find_by(name: 'hcv') || SvcMonitor.create!(name: 'hcv', up: true)) 

if json['status'] == 'success'
  puts "We're up.."
  hcv.update_attribute(:up, true)
else
  puts "We're down!"
  hcv.send_hcv_alert
  hcv.update_attribute(:up, false)
end

