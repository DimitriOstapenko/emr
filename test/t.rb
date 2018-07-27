
require_relative '../config/environment'

@paystub = Paystub.find(41)
@sdate = Date.new(@paystub.year, @paystub.month)
@edate = 1.month.since(@sdate)

svcs =  Claim.joins(:services).where(provider_no: @paystub.doctor.provider_no).where(date_paid: (@sdate..@edate)).reorder('').group('services.svc_date')

svcs.each do |s|
	puts s.claim_no
end
 

