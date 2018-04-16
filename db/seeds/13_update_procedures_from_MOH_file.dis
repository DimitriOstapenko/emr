#
# Update fees and effective_date for all procedures from latest MOH file 
# MaySOB2017_procedures_from_MOH.txt

require_relative '../../config/environment'
require 'date'

puts "About to update procedures from official MOH file"
found = not_found = fee_mismatch_count = 0

  File.foreach(Rails.root.join('lib', 'seeds', 'MaySOB2017_procedures_from_MOH.txt')) do |line|
    code = line[0,4]

    pp = Procedure.where("code like ?", "#{code}%")
   
    if pp.blank?
	    puts "Procedure not found: '#{code}'"
	    not_found += 1
    else
      p = pp[0]
      
      p.prov_fee = line[20,11].to_i/100
      p.ass_fee = line[31,11].to_i/100
      p.spec_fee = line[42,11].to_i/100
      p.ana_fee = line[53,11].to_i/100
      p.non_ana_fee = line[64,11].to_i/100
      p.eff_date = Date.strptime(line[4,8], "%Y%m%d")
#      term_date = line[12,8].to_i
      p.save
      if p.prov_fee > 0     
        fees_dont_match = ((p.cost - p.prov_fee/100) > 1)
	if fees_dont_match
	   fee_mismatch_count += 1	
           puts "found #{pp.count} '#{code}' and fees don't match" 
	else 
#         puts "found #{pp.count} '#{code}' and fees match"
	end   
        found += 1
      end 	
    end
  end

  puts "Modified: #{found} procedures; Not found: #{not_found} procedures; #{fee_mismatch_count} provider fees did not match"

