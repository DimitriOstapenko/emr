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
               #{pat.full_name} (#{pat.sex})
               #{pat.addr}
               #{pat.city}, #{pat.prov} #{pat.postal}

               <b>Phone</b>: #{pat.phone} File: #{pat.id}
               <b>DOB</b>: #{pat.dob} Age: #{pat.age} 
               <b>HCN</b>: #{pat.ohip_num} #{pat.ohip_ver} (#{pat.hin_prov}) 
               <b>File#</b>: #{pat.id}"

    visitinfo="<b>Provider</b>: Dr. #{visit.doctor.lname}
              Family Doctor: #{pat.family_dr} 

              Date: #{visit.entry_ts.strftime("%d-%m-%Y")}
              Time: #{visit.entry_ts.strftime("%H:%M")}

              Visit Type: Walk In
              Visit Ref#: #{visit.id}"

    medinfo = "<b>Medications</b>: #{pat.medications}"

    pdf.stroke do
                pdf.line_width=1
                pdf.horizontal_line 0,200.mm, :at => 215.mm
                pdf.horizontal_line 0,200.mm, :at => 183.mm
                pdf.horizontal_line 0,200.mm, :at => 173.mm
                pdf.horizontal_line 0,200.mm, :at => 163.mm
                pdf.horizontal_line 0,200.mm, :at => 153.mm
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
    pdf.draw_text "Allergies: ", :at => [5.mm,175.mm], style: :bold
    pdf.draw_text allergies, :at => [35.mm,175.mm]
    pdf.draw_text "Reason:", at: [5.mm,165.mm], style: :bold
    pdf.draw_text reason, at: [26.mm,165.mm]
    pdf.draw_text 'Vitals:', at: [5.mm,155.mm], style: :bold
    pdf.draw_text "T: #{visit.temp}", at: [35.mm,155.mm]
    pdf.draw_text "BP: #{visit.bp}", at: [69.mm,155.mm]
    pdf.draw_text "WT: #{visit.weight}", at: [118.mm,155.mm]
    pdf.draw_text "HR: #{visit.pulse}", at: [160.mm,155.mm]

    pdf.draw_text "Notes:", at: [5.mm,148.mm], style: :bold
    pdf.text_box visit.notes, :at => [5.mm,140.mm],
         :width => 195.mm,
         :height => 110.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 9,
         :inline_format => true

    pdf.draw_text "Diagnosis", at: [5.mm,25.mm]
    pdf.draw_text 'Signature:', at: [5.mm,15.mm]

    pdf.draw_text CLINIC_NAME, at: [5.mm,5.mm], style: :bold
    pdf.draw_text "#{CLINIC_ADDR} t:#{CLINIC_PHONE} f:#{CLINIC_FAX}", at: [5.mm,1.mm], size: 9 #, style: [:bold,:italic] 

    return pdf
  end # build_visit_form








# This PDF receipt is generated for 3RD party services only; 1 3RD party service per visit (1st)
  def build_receipt ( pat, visit )

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

    pdf.draw_text visit.proc_descr(visit.invoice_pcode), at: [5.mm, 162.mm]
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

# Generate PDF invoice, return pdf object
  def build_invoice ( pat, visit )

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])
    pdf.font "Courier"
    pdf.font_size 10

# 3rd party service in the list of services?
    _3rdind = visit._3rd_index
    if  _3rdind.nil?
      pdf.text "This visit does not have 3rd party service. No Invoice", size: 16, :align => :center
      return pdf
    end

    provider = Provider.find ( visit.provider_id )
    today  = Date.today.strftime "%B %d, %Y"
    servstr = Date.today.to_s.ljust(85)
    servstr[15] = visit.invoice_pcode    
    servstr[30] = visit.invoice_units.to_s
    servstr[40] = "$#{visit.invoice_amount}"      
#    servstr[52] = "$#{visit.invoice_amount}" 
#    servstr[65] = '$0.00'   
                  
    inv_no = visit.invoice_id.to_s.rjust(3, "0")
    serviceinfo = "<b> Service details </b>:

                   Date           Descr         Qty       Charges     Payments     Balance   
                  #{servstr} 
                  "
    pdf.font "Courier"
    pdf.stroke_rectangle [0,240.mm], 200.mm,113.mm
    pdf.text 'Invoice for Professional Services', size: 14, :align => :center
    pdf.text 'Dr.' + visit.doctor.full_name,  size: 14, :align => :center
    
    pdf.text CLINIC_NAME, align: :center
    pdf.text CLINIC_ADDR, align: :center

    pdf.draw_text "Invoice: #{inv_no}", at: [170.mm,243.mm], style: :bold
    pdf.draw_text "NOTES: Please make payable to #{CLINIC_NAME}", at: [5.mm,132.mm]

    pdf.stroke do
	    pdf.line_width=0.2.mm
                pdf.horizontal_line 0,200.mm, :at => 195.mm
                pdf.horizontal_line 0,200.mm, :at => 140.mm
                pdf.horizontal_line 0,200.mm, :at => 35.mm
                pdf.vertical_line 195.mm,240.mm, :at => 120.mm
              end

    patinfo = "<b>Patient:</b> 
    
               #{ pat.full_name} (#{pat.sex})
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
    
    pdf.draw_text visit.proc_descr(visit.invoice_pcode), at: [5.mm, 162.mm]

# Tear-off footer     
    pdf.draw_text 'Submit this portion with your payment', at: [60.mm, 30.mm], style: :bold

    pdf.draw_text "Date: #{today}", at: [2.mm, 25.mm]
    pdf.draw_text "Patient: #{pat.full_name}", at: [2.mm, 18.mm]
    pdf.draw_text "Billed To: #{provider.name}", at: [2.mm, 11.mm]
    
    pdf.draw_text "Invoice: #{inv_no}", at: [140.mm, 25.mm]
    pdf.draw_text "Amount Billed: $#{visit.invoice_amount}", at: [140.mm, 18.mm]
    pdf.draw_text "Amount Paid: $", at: [140.mm, 11.mm]
    pdf.stroke { pdf.horizontal_line 170.mm,195.mm, :at => 11.mm }

    pdf.draw_text "Please make cheque payable to: #{CLINIC_NAME}", at: [25.mm, 1.mm], style: :italic

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

# Generate patient's label
  def build_label ( pat )
    @label = label_string ( pat )
    pdf = Prawn::Document.new(page_size: [90.mm, 29.mm], page_layout: :portrait, margin: [0.mm,2.mm,1.mm,1.mm])
    pdf.font "Courier", :style => :bold
    pdf.text_box @label, :at => [3.mm,26.mm],
         :width => 84.mm,
         :height => 25.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 2.mm

    return pdf
  end
  
  def build_report( report, visits )
    @doc = Doctor.find(report.doc_id)
    sdate = report.sdate.strftime("%d %b %Y")
    edate = report.edate.strftime("%d %b %Y")
    date_range = report.rtype == 1 ? sdate : "#{sdate} - #{edate}" 
    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])

    pdf.text "#{CLINIC_NAME} #{CLINIC_ADDR} #{CLINIC_PHONE} #{CLINIC_FAX}", align: :center, size: 8
    pdf.move_down 5.mm
    pdf.text "#{REPORT_TYPES.invert[report.rtype]} Billing Report For Dr. #{@doc.lname}, Prov# #{@doc.provider_no} Group# #{GROUP_NO}", align: :center, size: 12, style: :bold
    pdf.text "For services performed:  #{date_range}", align: :center, size: 12, style: :bold
    pdf.text "(Sorted by visit time, last to first)", align: :center, size: 10
    pdf.move_down 5.mm

    pdf.font "Courier"
    pdf.font_size 9
    @servcounts =  {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 =>0 }
    @totals =  {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 =>0 }

    rows =  [[ "Patient", "OHIP#", "DOB", "Serv.", "U", "Fee", "Diag", "Status", "Acct#"]]
    visits.all.each do |v|
      pat = Patient.find(v.patient_id)
      next unless v.fee > 0
      rows += [[ pat.full_name[0..19], pat.ohip_num_full, pat.dob.strftime("%d/%m/%Y"), v.proc_code[0..4], v.units, v.fee, v.diag_scode, v.export_file, pat.id ]]
      @totals[v.bil_type] += v.fee if v.bil_type
      @servcounts[v.bil_type] += 1 if v.bil_type
      serv = v.services
      serv.shift
      serv.each do |s|
	rows += [[ '','','', s[:pcode], s[:units], s[:fee], v.diag_scode, v.export_file, pat.id ]]
	@totals[s[:btype]] += s[:fee] if s[:btype]
        @servcounts[s[:btype]] += 1 if s[:btype]
      end
    end

      pdf.table rows do |t|
        t.cells.border_width = 0 
        t.column_widths = [43.mm, 30.mm, 25.mm, 18.mm, 6.mm, 15.mm, 12.mm, 28.mm, 15.mm  ]
        t.header = true 
        t.row(0).font_style = :bold
        t.position = 10.mm
      end
      
      pdf.move_down 10.mm
      pdf.span(160.mm, :position => :center) do
        pdf.text "Total Claims: #{visits.count}", size: 10
        totals = [[ '', "HCP", "RMB", "INVOICE", "CASH", "WCB", "PRV", "Total" ]]
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

private 

  def label_string ( pat )
     dob = pat.dob.strftime("%d-%b-%Y") rescue ''
     exp_date = pat.hin_expiry.strftime("%m/%y") rescue ''

     "#{pat.full_name} (#{pat.sex})
     #{pat.addr} #{pat.city}, #{pat.prov} #{pat.postal} 
     DOB: #{dob}, #{pat.age} y.o 
     H#: #{pat.ohip_num} V:#{pat.ohip_ver} Exp:#{exp_date} (#{pat.hin_prov})
     Tel: #{pat.phonestr} File: #{pat.id}"
  end

  end # Forms

end

