#
# Controller pdf forms functionality factored out
#

module My

  module Forms

    require 'prawn'
    require 'prawn/table'
    require "prawn/measurement_extensions"

    CLINICINFO = "<b>Clinic:</b> 

                 #{CLINIC_NAME} 
                 #{CLINIC_ADDR} 
		 
                 Phone: #{CLINIC_PHONE}
		 Fax:   #{CLINIC_FAX}".freeze

# Generate visit form in PDF, return pdf object
  def build_visit_form ( pat, visit )

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])

    pdf.font "Courier"
    pdf.font_size 12
    pdf.stroke_rectangle [0,260.mm], 200.mm,260.mm

    patinfo = "<b>Patient</b>:
               <b>#{pat.full_name}</b> (#{pat.sex})
               #{pat.addr}
               #{pat.city}, #{pat.prov} #{pat.postal}

               <b>Phone: #{pat.phonestr} </b>File: #{pat.id}

               <b>DOB</b>: #{pat.dob} <b>Age</b>: #{pat.age_str} 
               <b>HCN</b>: #{pat.ohip_num} #{pat.ohip_ver} (#{pat.hin_prov})"

    visitinfo="<b>Provider</b>:
	      Dr. #{visit.doctor.lname}
              Family Doctor: #{pat.family_dr} 

              Date: #{visit.entry_ts.strftime("%d-%m-%Y")}
              Time: #{visit.entry_ts.strftime("%H:%M")}

              Visit Type: Walk In
              Visit Ref#: #{visit.id}"

    medinfo = "<b>Medications</b>: #{pat.medications}"

    pdf.stroke do
                pdf.line_width=1
                pdf.horizontal_line 0,200.mm, :at => 215.mm
                pdf.horizontal_line 0,200.mm, :at => 193.mm
                pdf.horizontal_line 0,200.mm, :at => 183.mm
                pdf.horizontal_line 0,200.mm, :at => 173.mm
                pdf.horizontal_line 0,200.mm, :at => 163.mm
                pdf.vertical_line 215.mm,260.mm, :at => 100.mm
                pdf.horizontal_line 32.mm,195.mm, :at => 25.mm
                pdf.horizontal_line 32.mm,195.mm, :at => 15.mm
              end

# Provider Info box    
    pdf.text_box visitinfo, :at => [5.mm,257.mm],
         :width => 100.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

# Patient Info box         
    pdf.text_box patinfo, :at => [105.mm,257.mm],
         :width => 100.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

# Medications box
    pdf.text_box medinfo, :at => [5.mm,212.mm],
         :width => 195.mm,
         :height => 30.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

    allergies = pat.allergies[0,65] rescue ''
    reason = visit.reason[0,68] rescue ''
    pdf.draw_text "Allergies: ", :at => [5.mm,185.mm], style: :bold
    pdf.draw_text allergies, :at => [35.mm,185.mm]
    pdf.draw_text "Reason:", at: [5.mm,175.mm], style: :bold
    pdf.draw_text reason, at: [26.mm,175.mm]
    pdf.draw_text 'Vitals:', at: [5.mm,165.mm], style: :bold
    pdf.draw_text "T: #{visit.temp}", at: [35.mm,165.mm]
    pdf.draw_text "BP: #{visit.bp}", at: [69.mm,165.mm]
    pdf.draw_text "WT: #{visit.weight}", at: [118.mm,165.mm]
    pdf.draw_text "HR: #{visit.pulse}", at: [160.mm,165.mm]

    pdf.draw_text "Notes:", at: [5.mm,158.mm], style: :bold
    if !visit.notes.nil?
      pdf.text_box visit.notes, :at => [5.mm,152.mm],
         :width => 195.mm,
         :height => 110.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true
    end

    pdf.draw_text "Diagnosis", at: [5.mm,25.mm]
    pdf.draw_text 'Signature:', at: [5.mm,15.mm]

    pdf.draw_text CLINIC_NAME, at: [5.mm,5.mm], style: :bold
    pdf.draw_text "#{CLINIC_ADDR} t:#{CLINIC_PHONE} f:#{CLINIC_FAX}", at: [5.mm,1.mm], size: 9 #, style: [:bold,:italic] 

    return pdf
  end # build_visit_form

# This PDF receipt is generated for 3RD party services only; 1 3RD party service per visit (1st)
  def build_visit_receipt ( pat, visit )

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])
    pdf.font "Courier"
    pdf.font_size 10
    pdf.stroke_rectangle [0,240.mm], 200.mm,240.mm

    _3rdind = visit._3rd_index
    if  _3rdind.nil?
      pdf.text "This visit does not have 3rd party service", size: 16, :align => :center
      return pdf 
    end

    today  = Date.today.strftime "%B %d, %Y"
    pdf.font "Courier"
    pdf.text 'Receipt for Professional Services', size: 16, :align => :center
    pdf.text 'Dr.' + visit.doctor.full_name,  size: 16, :align => :center

    patinfo = "<b>Patient:</b> 
    
               #{pat.full_name} (#{pat.sex})
               #{pat.addr}
               #{pat.city}, #{pat.prov} #{pat.postal}
               Born: #{pat.dob} 
               HCN: #{pat.ohip_num} #{pat.ohip_ver} (#{pat.hin_prov})
               File: #{pat.id}"

        servstr = Date.today.to_s.ljust(85)
	servstr[15] = visit.invoice_pcode    
	servstr[30] = visit.invoice_units.to_s
	servstr[40] = "$#{visit.invoice_amount}"      
	servstr[52] = "$#{visit.invoice_amount}"       
	servstr[65] = '$0.00'   
                   
#                             1         2         3         4         5         6         7
#                    123456789012345678901234567890123456789012345678901234567890123456789012345

    serviceinfo = "<b> Service details </b>:  

                     Date           Descr         Qty       Charges     Payments     Balance   
		     #{servstr}"

# Clinic address box
    pdf.text_box CLINICINFO, :at => [5.mm,237.mm],
         :width => 95.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

# Patient Info box
    pdf.text_box patinfo, :at => [105.mm,237.mm],
         :width => 100.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

# Service description box:
    pdf.text_box serviceinfo, :at => [5.mm,192.mm],
         :width => 200.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

    descr = visit.reason.blank? ? visit.proc_descr(visit.invoice_pcode) : visit.reason[0,90]
    pdf.draw_text descr, at: [5.mm, 162.mm]
    pdf.draw_text "Notes: #{visit.notes[0,68]}", :at => [5.mm,130.mm]

    pdf.stroke do
                pdf.line_width=1
                pdf.horizontal_line 0,200.mm, :at => 195.mm
                pdf.horizontal_line 0,200.mm, :at => 140.mm
                pdf.horizontal_line 0,200.mm, :at => 126.mm
                pdf.vertical_line 195.mm,240.mm, :at => 100.mm
              end

    return pdf
  end # build_receipt

# Generate specialist referral form
  def build_referral_form ( pat, visit )
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])
    pdf.font "Courier"
    pdf.font_size 10

    pdf.text "REFERRAL FORM ", align: :center, size: 12, style: :bold
    pdf.move_down 5.mm

    pdf.text CLINIC_NAME, align: :center, size: 12
    pdf.text CLINIC_ADDR, align: :center, size: 12
    pdf.text 'Tel: '+CLINIC_PHONE + ' Fax: ' + CLINIC_FAX, align: :center

    meds = pat.medications[0,77] rescue ''
    algies = pat.allergies[0,77] rescue ''

    pdf.stroke do
            pdf.line_width=0.2.mm
	        pdf.horizontal_line 20.mm,195.mm, :at => 218.mm
	        pdf.horizontal_line 20.mm,100.mm, :at => 206.mm
	        pdf.horizontal_line 120.mm,195.mm, :at => 206.mm
                pdf.horizontal_line 0,195.mm, :at => 200.mm
                pdf.horizontal_line 0,195.mm, :at => 150.mm
                pdf.vertical_line 150.mm,200.mm, :at => 100.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 125.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 115.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 105.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 95.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 85.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 75.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 60.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 50.mm
		pdf.horizontal_line 50.mm,195.mm, :at => 5.mm
              end

    pdf.draw_text "To :", at: [2.mm, 218.mm], style: :bold
    pdf.draw_text "Tel:", at: [2.mm, 206.mm], style: :bold
    pdf.draw_text "Fax:", at: [107.mm, 206.mm], style: :bold

    pdf.draw_text "Patient:", at: [2.mm, 194.mm], style: :bold
    pdf.draw_text "Name:", at: [2.mm, 188.mm]
    pdf.draw_text "#{pat.full_name} (#{pat.sex})", at: [16.mm, 188.mm]
    pdf.draw_text "Address:", at: [2.mm, 182.mm]
    pdf.draw_text "#{pat.addr}", at: [22.mm, 182.mm]
    pdf.draw_text "#{pat.city}, #{pat.prov} #{pat.postal}", at: [22.mm, 177.mm]
    pdf.draw_text "Telephone:", at: [2.mm, 168.mm]
    pdf.draw_text "#{pat.phonestr}", at: [25.mm, 168.mm]
    pdf.draw_text "DOB:", at: [2.mm, 161.mm]
    pdf.draw_text "#{pat.dob}", at: [12.mm, 161.mm]
    pdf.draw_text "VisitId:", at: [55.mm, 161.mm]
    pdf.draw_text "#{visit.id}", at: [75.mm, 161.mm]
    pdf.draw_text "HC#:", at: [2.mm, 155.mm]
    pdf.draw_text "#{pat.ohip_num} #{pat.ohip_ver}", at: [12.mm, 155.mm]
    pdf.draw_text "File#:", at: [55.mm, 155.mm]
    pdf.draw_text "#{pat.id}", at: [75.mm, 155.mm]
    
    pdf.draw_text "Referring Doctor:", at: [102.mm, 194.mm], style: :bold
    pdf.draw_text "Name:", at: [102.mm, 182.mm]
    pdf.draw_text " Dr. #{visit.doctor.lname}", at: [128.mm, 182.mm]
    pdf.draw_text "Billing No:", at: [102.mm, 174.mm]
    pdf.draw_text "#{visit.doctor.provider_no}", at: [128.mm, 174.mm]
    pdf.draw_text "Date:", at: [102.mm, 165.mm]
    pdf.draw_text Date.today, at: [128.mm, 165.mm]
    pdf.draw_text "Signature:", at: [102.mm, 156.mm]

    pdf.draw_text "Reason for ", at: [2.mm, 133.mm], style: :bold
    pdf.draw_text "Referral:", at: [2.mm, 126.mm], style: :bold
    pdf.draw_text "Medications:", at: [2.mm, 60.mm], style: :bold
    pdf.draw_text "#{meds}", at: [32.mm, 61.mm]
    pdf.draw_text "Allergies:", at: [2.mm, 50.mm], style: :bold
    pdf.draw_text "#{algies}", at: [32.mm, 51.mm]
    
    pdf.draw_text "Thank you for seeing this patient", at: [2.mm, 20.mm], size: 12, style: :bold
    
    pdf.draw_text "Appointment Date:", at: [2.mm, 5.mm], style: :bold

    return pdf
  end

# Generate patient's Lab label
  def build_label ( pat )
    @label = label_string ( pat )
    pdf = Prawn::Document.new(page_size: [90.mm, 29.mm], page_layout: :portrait, margin: [0.mm,2.mm,1.mm,1.mm])
    pdf.font "Helvetica", size: 10 
    pdf.text_box @label, :at => [2.mm,26.mm],
         :width => 65.mm,
         :height => 28.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
	 :leading => 0,  # line spacing
         :inline_format => true

    return pdf
  end
 
# Generate patient's Address label
  def build_address_label ( pat )
    @label = addr_label_string ( pat )
    pdf = Prawn::Document.new(page_size: [90.mm, 29.mm], page_layout: :portrait, margin: [0.mm,2.mm,1.mm,1.mm])
    pdf.font "Helvetica", size: 11 
    pdf.text_box @label, :at => [2.mm,24.mm],
         :width => 85.mm,
         :height => 28.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 10,
	 :leading => 0,  # line spacing
         :inline_format => true

    return pdf
  end
  
# Build invoice for given patient  
  def build_invoice ( inv )

    pat = Patient.find(inv.patient_id)
    if  pat.blank?
      pdf.text "Patient not found in DB. Please create patient first", size: 16, :align => :center
      return pdf
    end

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])
    pdf.font "Courier"
    pdf.font_size 10

    provider = Provider.find ( inv.billto )
    if provider.blank?
       pdf.text "Provider with id of #{inv.billto} does not exist in DB", size: 16, :align => :center
       return pdf
    end

    today  = Date.today.strftime "%B %d, %Y"
    servstr = Date.today.to_s.ljust(85)
    servstr[15] = 'Invoice'   
    servstr[30] = '1'
    servstr[40] = "$#{inv.amount}"      
                  
    inv_no = inv.id.to_s.rjust(3, "0")
    serviceinfo = "<b> Service details </b>:

                   Date           Code         Qty       Charges     Payments     Balance   
                  #{servstr} 
                  "
    pdf.font "Courier"
    pdf.stroke_rectangle [0,240.mm], 200.mm,113.mm
    pdf.text 'Invoice for Professional Services', size: 14, :align => :center
    
    pdf.text CLINIC_NAME, align: :center
    if inv.doctor.present?
       pdf.text "Dr. #{inv.doctor.full_name}",  size: 12, :align => :center
    end   
    pdf.text CLINIC_ADDR, align: :center

    pdf.draw_text "Invoice: #{inv_no}", at: [172.mm,243.mm], style: :bold
    if inv.doctor.present?
      pdf.draw_text "NOTES: Please make payable to Dr. #{inv.doctor.full_name}", at: [5.mm,132.mm], style: :italic
    else
      pdf.draw_text "NOTES: Please make payable to #{CLINIC_NAME}", at: [5.mm,132.mm], style: :italic
    end

    pdf.stroke do
	    pdf.line_width=0.2.mm
                pdf.horizontal_line 0,200.mm, :at => 195.mm
                pdf.horizontal_line 0,200.mm, :at => 140.mm
                pdf.horizontal_line 0,200.mm, :at => 35.mm
                pdf.vertical_line 195.mm,240.mm, :at => 120.mm
              end

    patinfo = "<b>Patient:</b> 
    
               #{pat.full_name} (#{pat.sex})
               #{pat.addr}
               #{pat.city}, #{pat.prov} #{pat.postal}
	       
               Born: #{pat.dob} 
               File: #{pat.id}"
    invoiceto = "<b>Invoice To</b>: #{provider.name}
 	        #{provider.addr1}	
 	        #{provider.addr2}	
                #{provider.city}, #{provider.prov} #{provider.postal}
     		  
     		 Date: #{today} "

    pdf.text_box patinfo, :at => [122.mm,237.mm],
         :width => 80.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

    pdf.text_box invoiceto, :at => [5.mm,237.mm],
         :width => 120.mm,
         :height => 45.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true	

    pdf.text_box serviceinfo, :at => [5.mm,192.mm],
         :width => 190.mm,
         :height => 50.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true
    
    pdf.draw_text inv.notes[0,85], at: [5.mm, 162.mm]

# Tear-off footer     
    pdf.draw_text 'Submit this portion with your payment', at: [60.mm, 30.mm], style: :bold

    pdf.draw_text "Date: #{today}", at: [2.mm, 25.mm]
    pdf.draw_text "Patient: #{pat.full_name}", at: [2.mm, 18.mm]
    pdf.draw_text "Billed To: #{provider.name}", at: [2.mm, 11.mm]
    
    pdf.draw_text "Invoice: #{inv_no}", at: [140.mm, 25.mm]
    pdf.draw_text "Amount Billed: $#{inv.amount}", at: [140.mm, 18.mm]
    pdf.draw_text "Amount Paid: $", at: [140.mm, 11.mm]
    pdf.stroke { pdf.horizontal_line 170.mm,195.mm, :at => 11.mm }

#    pdf.draw_text "Please make cheque payable to: #{CLINIC_NAME}", at: [25.mm, 1.mm], style: :italic

    return pdf

  end # build_invoice

# Generate specialist referral form
  def build_referral_form ( pat, visit )
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])
    pdf.font "Courier"
    pdf.font_size 10

    pdf.text "REFERRAL FORM ", align: :center, size: 12, style: :bold
    pdf.move_down 5.mm

    pdf.text CLINIC_NAME, align: :center, size: 12
    pdf.text CLINIC_ADDR, align: :center, size: 12
    pdf.text 'Tel: '+CLINIC_PHONE + ' Fax: ' + CLINIC_FAX, align: :center

    meds = pat.medications[0,77] rescue ''
    algies = pat.allergies[0,77] rescue ''

    pdf.stroke do
            pdf.line_width=0.2.mm
	        pdf.horizontal_line 20.mm,195.mm, :at => 218.mm
	        pdf.horizontal_line 20.mm,100.mm, :at => 206.mm
	        pdf.horizontal_line 120.mm,195.mm, :at => 206.mm
                pdf.horizontal_line 0,195.mm, :at => 200.mm
                pdf.horizontal_line 0,195.mm, :at => 150.mm
                pdf.vertical_line 150.mm,200.mm, :at => 100.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 125.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 115.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 105.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 95.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 85.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 75.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 60.mm
		pdf.horizontal_line 30.mm,195.mm, :at => 50.mm
		pdf.horizontal_line 50.mm,195.mm, :at => 5.mm
              end

    pdf.draw_text "To :", at: [2.mm, 218.mm], style: :bold
    pdf.draw_text "Tel:", at: [2.mm, 206.mm], style: :bold
    pdf.draw_text "Fax:", at: [107.mm, 206.mm], style: :bold

    pdf.draw_text "Patient:", at: [2.mm, 194.mm], style: :bold
    pdf.draw_text "Name:", at: [2.mm, 188.mm]
    pdf.draw_text "#{pat.full_name} (#{pat.sex})", at: [16.mm, 188.mm]
    pdf.draw_text "Address:", at: [2.mm, 182.mm]
    pdf.draw_text "#{pat.addr}", at: [22.mm, 182.mm]
    pdf.draw_text "#{pat.city}, #{pat.prov} #{pat.postal}", at: [22.mm, 177.mm]
    pdf.draw_text "Telephone:", at: [2.mm, 168.mm]
    pdf.draw_text "#{pat.phonestr}", at: [25.mm, 168.mm]
    pdf.draw_text "DOB:", at: [2.mm, 161.mm]
    pdf.draw_text "#{pat.dob}", at: [12.mm, 161.mm]
    pdf.draw_text "VisitId:", at: [55.mm, 161.mm]
    pdf.draw_text "#{visit.id}", at: [75.mm, 161.mm]
    pdf.draw_text "HC#:", at: [2.mm, 155.mm]
    pdf.draw_text "#{pat.ohip_num} #{pat.ohip_ver}", at: [12.mm, 155.mm]
    pdf.draw_text "File#:", at: [55.mm, 155.mm]
    pdf.draw_text "#{pat.id}", at: [75.mm, 155.mm]
    
    pdf.draw_text "Referring Doctor:", at: [102.mm, 194.mm], style: :bold
    pdf.draw_text "Name:", at: [102.mm, 182.mm]
    pdf.draw_text " Dr. #{visit.doctor.lname}", at: [128.mm, 182.mm]
    pdf.draw_text "Billing No:", at: [102.mm, 174.mm]
    pdf.draw_text "#{visit.doctor.provider_no}", at: [128.mm, 174.mm]
    pdf.draw_text "Date:", at: [102.mm, 165.mm]
    pdf.draw_text Date.today, at: [128.mm, 165.mm]
    pdf.draw_text "Signature:", at: [102.mm, 156.mm]

    pdf.draw_text "Reason for ", at: [2.mm, 133.mm], style: :bold
    pdf.draw_text "Referral:", at: [2.mm, 126.mm], style: :bold
    pdf.draw_text "Medications:", at: [2.mm, 60.mm], style: :bold
    pdf.draw_text "#{meds}", at: [32.mm, 61.mm]
    pdf.draw_text "Allergies:", at: [2.mm, 50.mm], style: :bold
    pdf.draw_text "#{algies}", at: [32.mm, 51.mm]
    
    pdf.draw_text "Thank you for seeing this patient", at: [2.mm, 20.mm], size: 12, style: :bold
    
    pdf.draw_text "Appointment Date:", at: [2.mm, 5.mm], style: :bold

    return pdf
 
  end

# Generate doctor's billing report
  def build_report( report, visits )
    @doc = Doctor.find(report.doc_id)
    sdate = report.sdate.strftime("%d %b %Y")
    edate = report.edate.strftime("%d %b %Y")
    date_range = report.rtype == 1 ? sdate : "#{sdate} - #{edate}" 
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,20.mm,10.mm])

    pdf.text "#{CLINIC_NAME} #{CLINIC_ADDR} #{CLINIC_PHONE} #{CLINIC_FAX}", align: :center, size: 8
    pdf.move_down 5.mm
    pdf.text "#{REPORT_TYPES.invert[report.rtype]} Billing Report For Dr. #{@doc.lname}, Prov# #{@doc.provider_no} Group# #{GROUP_NO}", align: :center, size: 12, style: :bold
    pdf.text "For services performed:  #{date_range}", align: :center, size: 12, style: :bold
    pdf.text "(Sorted by visit time, last to first)", align: :center, size: 10
    pdf.move_down 5.mm

    pdf.font "Courier"
    pdf.font_size 8
    @totals = {}
    @servcounts = {}
    @total_hcp_claims = 0
    (1..7).map{|key| @totals[key] = 0}
    (1..7).map{|key| @servcounts[key] = 0}

    rows =  [[ "Serv Date", "Patient", "OHIP#", "DOB", "Serv.", "Tp", "Fee", "Diag", "Status", "Acct#"]]
    visits.all.each do |v|
      pat = Patient.find(v.patient_id)
      next unless v.fee > 0
      @total_hcp_claims += 1 if v.hcp_services?
      status = v.billing_ref.present? ? v.billing_ref : v.status_str
      rows += [[ v.entry_ts.strftime("%d/%m/%Y"), pat.full_name[0..19], pat.ohip_num_full, pat.dob.strftime("%d/%m/%Y"), v.proc_code[0..4], v.bil_type_str, v.fee, v.diag_scode, status, v.id ]]
      @totals[v.bil_type] += v.fee if v.bil_type
      @servcounts[v.bil_type] += 1 if v.bil_type
      serv = v.services
      serv.shift
      serv.each do |s|
	rows += [[ '','','', '', s[:pcode], BILLING_TYPES.invert[s[:btype]].to_s, s[:fee], v.diag_scode, v.billing_ref, pat.id ]]
	@totals[s[:btype]] += s[:fee] if s[:btype]
        @servcounts[s[:btype]] += 1 if s[:btype]
      end
    end

      pdf.table rows do |t|
        t.cells.border_width = 0 
	t.column_widths = [22.mm, 38.mm, 28.mm, 22.mm, 15.mm, 8.mm, 12.mm, 10.mm, 22.mm, 12.mm  ]
        t.header = true 
        t.row(0).font_style = :bold
        t.position = 5.mm
	t.cells.padding = 3
	t.cells.style do |c|
		c.background_color = c.row.odd? ? 'EEEEEE' : 'FFFFFF'
         end
      end
      
      pdf.move_down 10.mm
      pdf.span(190.mm, :position => :center) do
        pdf.text "Total Claims: #{@total_hcp_claims}", size: 9
        totals = [[ '', "HCP", "RMB", "INVOICE", "CASH", "WCB", "PRV", 'IFH', "Total" ]]
        @fees = @totals.values
        @fees.push(@fees.sum)
        totals += [ @fees.map{|e| sprintf("$%-8.2f",e)}.unshift('Fees') ]
        @services = @servcounts.values
        @services.push(@services.sum)
        totals += [ @services.unshift('Services') ]
        pdf.table totals do |t|
          t.cells.border_width = 1
	  t.column_widths = 20.mm 
          t.header = true
          t.row(0).font_style = :bold
        end
      end
    return pdf
  end

# Generate doctor's monthly Pay Stub based on claims paid by MOH
  def build_paystub( paystub, claims_by_day )
    @doc = paystub.doctor
    @month  = Date::MONTHNAMES[paystub.month]
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,20.mm,10.mm])

    pdf.text "#{CLINIC_NAME} #{CLINIC_ADDR} #{CLINIC_PHONE} #{CLINIC_FAX}", align: :center, size: 8
    pdf.move_down 10.mm
    pdf.text "Monthly Payment Report For Dr. #{@doc.lname}, Prov# #{@doc.provider_no} Group# #{GROUP_NO}", align: :center, size: 12, style: :bold
    pdf.text "Covering MHO payments disbursed in #{@month} #{paystub.year}", align: :center, size: 12, style: :bold
    pdf.text "(Grouped by service date)", align: :center, size: 10
    pdf.move_down 10.mm

    pdf.font "Courier"
    pdf.font_size 9

    @ttl_claims = @ttl_hcp_svcs = @ttl_rmb_svcs = @ttl_subm_amt = @ttl_paid_amt = 0
    rows =  [[ "Svc Date", "Claims", "Services",  "Pmt Pgm",  "Subm.", "Paid", "Balance", "Date paid" ]]
    claims_by_day.each do |cl|
	    rows += [[ cl[0].to_date.strftime("%d/%m/%Y"), cl[1], cl[2], cl[3], cl[4], cl[5], sprintf("%.2f",cl[5]-cl[4]), paystub.date_paid ]]
       @ttl_claims += cl[1]
       @ttl_hcp_svcs += cl[2] if cl[3] == 'HCP'
       @ttl_rmb_svcs += cl[2] if cl[3] == 'RMB'
       @ttl_subm_amt += cl[4]
       @ttl_paid_amt += cl[5]
    end

      pdf.table rows do |t|
        t.cells.border_width = 0 
	t.column_widths = [28.mm, 20.mm, 20.mm, 20.mm, 20.mm, 20.mm, 20.mm  ]
        t.header = true 
        t.row(0).font_style = :bold
        t.position = 15.mm
	t.cells.padding = 3
	t.cells.style do |c|
		c.background_color = c.row.odd? ? 'EEEEEE' : 'FFFFFF'
         end
      end
 
      pdf.font_size 10
      pdf.move_down 15.mm
      pdf.span(165.mm, :position => :center) do
	      pdf.text "Total days worked: #{claims_by_day.count}"
        pdf.text "Total claims: #{@ttl_claims}"
        pdf.text "Total services: #{@ttl_hcp_svcs+@ttl_rmb_svcs}"
        pdf.text "Total HCP services: #{@ttl_hcp_svcs}"
        pdf.text "Total RMB services: #{@ttl_rmb_svcs}"
        pdf.move_down 6.mm
	pdf.text "Total submitted amount : #{sprintf("$%.2f",@ttl_subm_amt)}"
	pdf.text "Total amount paid by OHIP:  #{sprintf("$%.2f",@ttl_paid_amt)}" 
        pdf.move_down 6.mm
	pdf.text "Monthly Premium payment:  #{sprintf("$%.2f",paystub.monthly_premium_amt)}" 
	pdf.text "IFH Payments:  #{sprintf("$%.2f",paystub.ifh_amt)}" 
	pdf.text "Cash payments:  #{sprintf("$%.2f",paystub.cash_amt)}" 
	pdf.text "WCB Payments:  #{sprintf("$%.2f",paystub.wcb_amt)}" 
	pdf.text "Cash deposits:  #{sprintf("$%.2f",paystub.hc_dep_amt)}" 
        pdf.move_down 6.mm
	pdf.text "Total Gross Amount:  #{sprintf("$%.2f",paystub.gross_amt)}" 
	pdf.text "Total Net Amount based on #{@doc.percent_deduction}% deduction:  #{sprintf("$%.2f",paystub.net_amt)}" 
      end
    return pdf
  end

private 

  def label_string ( pat )
     dob = pat.dob.strftime("%d-%b-%Y") rescue ''
     exp_date = pat.hin_expiry.strftime("%m/%y") rescue ''

     "<b>#{pat.lname}, #{pat.fname} (#{pat.sex}), #{pat.age_str}</b> 
     #{pat.addr} #{pat.city}, #{pat.prov} 
     DOB: <b>#{dob}</b> File: #{pat.id}
     H#: #{pat.ohip_num} #{pat.ohip_ver} (#{pat.hin_prov})
     Tel: <b>#{pat.phonestr}</b>"
  end

  def addr_label_string ( pat )
     "<b>#{pat.lname}, #{pat.fname} </b> 

     #{pat.addr} #{pat.city}, #{pat.prov} #{pat.postal}"
  end

  end # Forms

end # My

