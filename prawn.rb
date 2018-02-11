 require 'prawn'
 require "prawn/measurement_extensions"

 pdf = Prawn::Document.new(page_size: [90.mm, 29.mm], page_layout: :portrait, margin: [0.mm,3.mm,1.mm,1.mm])
 
content = 
'OSTAPENKO, DMITRI 
147 CRESTVIEW AVE xxxxxxx xxx x x x x x xxxxxxxxxxxxxx xxxxxxx x x xx x xxxxxxx xxxxxx xxxxxxx xx xx x xx xxxxxxx
ANCASTER, ON L9G1C9
DOB: 21-May-1959 58 yr M
H#: 2414343067 V: FX
Tel: 905-304-3921  File: 11'

#	pdf.stroke_axis
#	pdf.stroke_rectangle [1.mm,27.mm], 88.mm,26.mm
 
 pdf.font "Courier"
pdf.text_box content, :at => [5.mm,26.mm],
	 :width => 82.mm,
	 :height => 27.mm,
 	 :overflow => :shrink_to_fit,
	 :min_font_size => 1.mm

 pdf.render_file('prawn.pdf')


#stroke_axis
#stroke do
# rectangle [100, 300], 100, 200
# rounded_rectangle [300, 300], 100, 200, 20
#end
