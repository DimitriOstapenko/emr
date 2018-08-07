
require_relative '../config/environment'

@report = Report.find(131)
prov_no = @report.doctor.provider_no rescue 0
puts prov_no
puts @report.sdate
puts @report.edate

@claims = Claim.joins(:services).where(provider_no: prov_no).where(date_paid: (@report.sdate..@report.edate)).reorder('').group('claims.claim_no').order('services.svc_date')


puts @claims.count
