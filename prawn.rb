 require 'prawn'
 require "prawn/measurement_extensions"

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

content = "Patient: SMITH,JOHN (M)
	   123 KING ST. WEST
	   HAMILTON, ON L9A A8A

	   Phone: 416-999-9999 File: 123455
	   DOB: 1-MAy-2000 Age: 17 y/o
	   HCN: 5700 168 742 MF (ON)"

# Patient Info box	   
  pdf.text_box content, :at => [5.mm,255.mm],
	 :width => 100.mm,
	 :height => 45.mm,
 	 :overflow => :shrink_to_fit,
	 :min_font_size => 9

  pdf.draw_text 'Medications:', :at => [105.mm,252.mm]

provider = 'Provider: John White
	    Family Doctor: Dr. Good'

  pdf.text_box provider, :at => [5.mm,210.mm], :width => 90.mm, :height => 22.mm
  
date_time = 'Date: 31-Oct-2017
	     Time: 11:42

	     Visit Id: 12345'

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
	  
 pdf.render_file('prawn.pdf')

