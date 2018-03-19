module My

  module Reports

    require 'prawn'
    require "prawn/measurement_extensions"

# Generate visit form in PDF, return pdf object
  def build_visit_form ( pat, visit )

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])
 
    pdf.font "Courier"
    pdf.stroke_rectangle [0,260.mm], 200.mm,260.mm

    pdf.stroke do
		pdf.line_width=1
		pdf.horizontal_line 0,200.mm, :at => 215.mm
		pdf.horizontal_line 0,200.mm, :at => 183.mm
		pdf.horizontal_line 0,200.mm, :at => 163.mm
		pdf.horizontal_line 0,200.mm, :at => 145.mm
		pdf.vertical_line 183.mm,260.mm, :at => 100.mm
   	      end

    content = "Patient: #{ pat.full_name} (#{pat.sex})
    	       #{pat.addr}
    	       #{pat.city}, #{pat.prov} #{pat.postal}

	       Phone: #{pat.phone} File: #{pat.id}
	       DOB: #{pat.dob} Age: #{pat.age} 
	       HCN: #{pat.ohip_num} #{pat.ohip_ver} (#{pat.hin_prov}) 
    	       EXP: #{pat.hin_expiry}"

# Patient Info box	   
    pdf.text_box content, :at => [5.mm,255.mm],
	 :width => 100.mm,
	 :height => 45.mm,
 	 :overflow => :shrink_to_fit,
	 :min_font_size => 9

    pdf.draw_text 'Medications:', :at => [105.mm,252.mm]
    pdf.draw_text "Provider: Dr. #{visit.doctor.lname}", :at => [5.mm,205.mm]
    pdf.draw_text "Family Doctor: Dr. #{pat.family_dr}", :at => [5.mm,195.mm]
  
    date_time = "Date: #{visit.entry_ts.strftime("%d-%m-%Y")}
		 Time: #{visit.entry_ts.strftime("%H:%M")}

		 Visit Ref#: #{visit.id}" 

    pdf.text_box date_time, :at => [105.mm,210.mm], :width => 90.mm, :height => 22.mm

    pdf.draw_text 'Reason:', :at => [5.mm,168.mm]
    pdf.draw_text 'Allergies:', :at => [5.mm,150.mm]
	
    pdf.stroke do
          pdf.line_width = 0.5
          pdf.horizontal_line 32.mm,80.mm, :at => 150.mm
          pdf.horizontal_line 85.mm,102.mm, :at => 150.mm
          pdf.horizontal_line 108.mm,123.mm, :at => 150.mm
          pdf.horizontal_line 131.mm,153.mm, :at => 150.mm
          pdf.horizontal_line 161.mm,173.mm, :at => 150.mm
          pdf.horizontal_line 183.mm,197.mm, :at => 150.mm
    end

    pdf.draw_text "T", :at => [81.mm,151.mm]
    pdf.draw_text "P", :at => [103.mm,151.mm]
    pdf.draw_text "BP", :at => [124.mm,151.mm]
    pdf.draw_text "WT", :at => [154.mm,151.mm]
    pdf.draw_text "HR", :at => [175.mm,151.mm]
    pdf.draw_text "Diagnosis", :at => [5.mm,20.mm]
    pdf.draw_text 'Signature:', :at => [5.mm,8.mm]

    pdf.stroke do
          pdf.line_width = 0.5
          pdf.horizontal_line 32.mm,195.mm, :at => 20.mm
          pdf.horizontal_line 32.mm,195.mm, :at => 8.mm
    end

    return pdf
  end # build_visit_form

# This PDF receipt is generated for 3RD party services only; 1 3RD party service per visit (1st)
  def build_receipt ( pat, visit )

    pdf = Prawn::Document.new( :page_size => "LETTER", margin: [10.mm,10.mm,10.mm,10.mm])

    _3rdind = visit._3rd_index
    return pdf if  _3rdind.nil?

    serv  = visit.services[_3rdind]
    today  = Date.today.strftime "%B %d, %Y"
    pdf.font "Courier"
    pdf.stroke_rectangle [0,240.mm], 200.mm,240.mm
    pdf.text 'Receipt for Professional Services', size: 16, :align => :center
    pdf.text 'Dr.' + visit.doctor.full_name,  size: 16, :align => :center

    patinfo = "<b>Patient:</b> 
    
              #{ pat.full_name} (#{pat.sex})
               #{pat.addr}
               #{pat.city}, #{pat.prov} #{pat.postal}
               Born: #{pat.dob} 
               HCN: #{pat.ohip_num} #{pat.ohip_ver} (#{pat.hin_prov})
               Exp: #{pat.hin_expiry}
               File: #{pat.id}"

    clinicinfo = "<b> Clinic: </b> 

                 #{CLINIC_NAME} 
                 #{CLINIC_ADDR} 
                 Phone: #{CLINIC_PHONE}
                 Fax:   #{CLINIC_FAX}
                 
                 Date: #{today}"

#                              1         2         3         4         5         6         7
#                     123456789012345678901234567890123456789012345678901234567890123456789012345

    serviceinfo = "<b> Service details </b>:

                     Date          Descr          Qty       Charges     Payments    Balance   
                    #{Date.today}    #{serv[:pcode]}         #{serv[:units]}          #{serv[:fee]}      #{serv[:fee]}       $0.00   
                   "

# Clinic address box
    pdf.text_box clinicinfo, :at => [5.mm,237.mm],
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

    pdf.draw_text "Notes: #{visit.notes}", :at => [5.mm,130.mm]

    pdf.stroke do
                pdf.line_width=1
                pdf.horizontal_line 0,200.mm, :at => 195.mm
                pdf.horizontal_line 0,200.mm, :at => 140.mm
                pdf.horizontal_line 0,200.mm, :at => 126.mm
                pdf.vertical_line 195.mm,240.mm, :at => 100.mm
              end


    return pdf
  end # build_receipt

  end # Reports

end

