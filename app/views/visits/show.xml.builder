xml.instruct!
xml.Claim do
  xml.careProvider do
	  xml.groupNumber @doctor.group_no
	  xml.providerNumber @doctor.provider_no
  end

  xml.diagnosticCode @visit.diag_scode

  xml.patient do
	  xml.firstName @patient.fname
	  xml.lastName @patient.lname
	  xml.gender @patient.full_sex
	  xml.dateOfBirth @patient.dob.strftime("%Y-%m-%dT%H:%M:%S")
	  xml.healthCard @patient.ohip_num
	  xml.versionCode @patient.ohip_ver
	  xml.provinceCode @patient.prov
  end

  xml.serviceDate @visit.entry_ts.strftime("%Y-%m-%dT%H:%M:%S")
 
  xml.services do  
	  @visit.services.each do |serv|
	    next unless hcp_procedure?(serv[:pcode])
	    xml.service do	  
		xml.serviceCode serv[:pcode]
		xml.quantity serv[:units]
	    end
	  end
  end

  xml.reference_id @visit.id
end

