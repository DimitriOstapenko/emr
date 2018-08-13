require_relative '../config/environment'
require 'find'

prov_no = "022337"
#prov_no = "016373"
ra_file = 'PH0078.735'

# Find PREMIUM PAYMENTS section for given provider, return as string array
def get_provider_premiums(arr, prov_no)
    arr.each_with_index do |str,i|
	    next unless str.match(/PREMIUM PAYMENTS/)
	    return [i+22,arr[i-1,23]] if arr[i+1,21].join('').match(/#{prov_no}/)
    end
end

# Find PAYMENT DISCOUNT SUMMARY section for given provider, return as string array
def get_provider_totals(arr, prov_no)
    ind  = 0
    outarr = []
    arr.each_with_index do |str,i|
      next unless str.match(/PHYSICIAN PAYMENT DISCOUNT SUMMARY REPORT/)
      ind = i
      break      
    end	   
    arr.slice!(0,ind)
     
    arr.each_with_index do |s,i|
       next if s.match(/^0078/) && !s.match(/#{prov_no}/)
       next if s.match(/TOTAL/)
       next if s.match(/HCP-IN/)
       outarr.push(s) 
       return outarr if s.match(/\*{70}/)
    end
end

msg = RaMessage.find_by(ra_file: ra_file)
return unless msg.present?
msg_arr = msg.msg_text.split("\n")

(index,section) = get_provider_premiums(msg_arr, prov_no)
msg_arr.slice!(0,index)
puts section.join"\n"

section2 = get_provider_totals(msg_arr, prov_no)
puts section2.join"\n"



