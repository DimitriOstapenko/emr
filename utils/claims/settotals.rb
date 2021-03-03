# Update totals in ra_messages

require_relative '../../config/environment'

RaMessage.all.each do |ra|
  claims = Claim.where("ra_file=?", ra.ra_file).count
  svcs = Claim.joins(:services).where("ra_file=?", ra.ra_file)
  services = svcs.count
  sum_claimed = svcs.pluck('amt_subm').sum
  sum_paid = svcs.pluck('amt_paid').sum
  puts "#{ra.ra_file}, #{claims}, #{services}, #{sum_claimed}, #{sum_paid}"
  ra.update(claims: claims, svcs: services, sum_claimed: sum_claimed, sum_paid: sum_paid)  
end
