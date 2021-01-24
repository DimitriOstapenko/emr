# Monitor HCV service, send alerts if down
# runs from cron every now and then (5min?)
#

require_relative '../config/environment'

hcv = SvcMonitor.find_by(name: 'hcv')
SvcMonitor.create!(name: 'hcv', up: true) unless hcv

# Get most recently validated patient
patient = Patient.where.not(validated_at: nil).where(prov: 'ON').last
response = patient.get_hcv_response
abort ("Did not get valid responce") unless response
json = JSON.parse(response.body)

if json['status'] == 'success'
  puts "#{Time.now} We're up.."
  hcv.update_attribute(:up, true)
else
  puts "#{Time.now} We're down!"
  hcv.send_hcv_alert
  hcv.update_attribute(:up, false)
end

