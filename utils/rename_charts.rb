# for all charts:
# - Rename chart file to {patient.id}.pdf
# - Set chart.chart to this new name
# - Set filename attribute to constructed name (patient.chart_filename )
#   
# NB! Disable uploader in charts before running!

require_relative '../config/environment'

puts "Renaming charts and setting attributes.."

count = 0
Chart.all.each do |chart|
  dir = File.dirname(chart.filespec) rescue nil
  next unless dir
  count += 1
  new_chart_pathname = File.join(dir, "#{chart.patient.id}.pdf")

#  File.rename( chart.filespec, new_chart_pathname) rescue nil

#  chart.update_attribute(:filename, chart.patient.chart_filename) 
#  chart.update_attribute(:chart, "#{chart.patient_id}.pdf") 
  chart.save!
  puts "id: #{chart.id} filename: #{chart.patient.chart_filename} chart: #{chart.patient.id} new filename: #{new_chart_pathname}"
end

puts "Processed #{count} charts"


