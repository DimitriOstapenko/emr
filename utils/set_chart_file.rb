#
# Set chart_file attribute for all patients that don't have it set 
# 

require_relative '../config/environment'

puts "Setting chart_file attribute for all patients with charts:"

before_count = Patient.where('chart_file is not null').count

added = 0
Patient.all.each do |p|
#  next unless p.chart_file.blank?
  chart = Dir.glob("#{Rails.root}/charts/**/#{p.lname}\,#{p.fname}*\.pdf")
  if !chart.blank?
     puts "*** Warning! More than 1 chart for patient #{p.lname} (#{p.id}); using the first one" if chart.count > 1
     p.update_attribute(:chart_file, chart[0])
     puts "#{added+1} : patient: #{p.id} : #{p.chart_file}"
     added += 1
  end
end

puts "#{added} charts assigned to patients in addition to #{before_count} that were already assigned"

