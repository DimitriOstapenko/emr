class VisitsController < ApplicationController

	before_action :logged_in_user, only: [:create, :destroy, :new, :index]
        before_action :current_doctor_set, only: :new  
	before_action :admin_user,   only: :destroy

  def new
        @patient = Patient.find(params[:patient_id])
        @visit = @patient.visits.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @visit = @patient.visits.build(visit_params)
    @visit.entry_ts = DateTime.now
    @visit.entry_by = current_user.name

    set_visit_fees ( @visit )

    if @visit.save
      @patient.last_visit_date = @visit.created_at	    
      @patient.save
      flash[:success] = "Visit saved"
      redirect_to @patient
    else
      render 'new'
    end
  end

  def destroy
    @patient = Patient.find(params[:patient_id])
    @visit.destroy
    flash[:success] = "Visit deleted"
    redirect_to request.referrer || root_url
  end

  def index
    @patient = Patient.find(params[:patient_id])
    if @patient.visits.any?
	    @visits = @patient.visits.paginate(page: params[:page])
	   render 'index'
      else
	   flash[:error] = 'No visits found for date ' + date.inspect 
	    render  body: nil
    end
  end

  def show
     @visit = Visit.find(params[:id])
     @patient = Patient.find(@visit.patient_id)
     @doctor = Doctor.find(@visit.doc_id)
  end

  def edit
     @visit = Visit.find(params[:id])
     @patient = Patient.find(@visit.patient_id)
     @doctor = Doctor.find(@visit.doc_id)
  end

  def update
    @visit = Visit.find(params[:id])
    @patient = Patient.find(@visit.patient_id)
    set_visit_fees( @visit )
    if @visit.update_attributes(visit_params)
      @patient.last_visit_date = @visit.created_at
      @patient.save
      flash[:success] = "Visit updated"
      redirect_to patient_path @patient 
    else
      render 'edit'
    end
  end

  def daysheet (defdate = Date.today)
      date = params[:date] || defdate
      flash.alert = 'Daysheet for ' + date
      @visits = Visit.where("date(created_at) = ?", date)  
      if @visits.any?
	   @visits = @visits.paginate(page: params[:page])
	   render 'index'
      else
	   flash[:error] = 'No visits found for date ' + date.inspect 
#           redirect_to visits_url
	    render "no_daysheet_found"
      end
  end

  def visitform
        @visit = Visit.find(params[:id])
	@patient = Patient.find(@visit.patient_id)
        pdf = build_visit_form( @patient, @visit )

        send_data pdf.render,
          filename: "label_#{@patient.full_name}",
          type: 'application/pdf',
          disposition: 'inline'
  end  

  private

    def visit_params
      params.require(:visit).permit(:vis_type,:diag_code,:proc_code, :proc_code2, :proc_code3, :proc_code4,
				    :units, :units2, :units3, :units4, :fee, :fee2, :fee3, :fee4,
				    :patient_id,:doc_id,:notes,:entry_ts,:status,:duration,:entry_by )
    end      

    def correct_user
      @visit = current_user.visits.find_by(id: params[:id])
      redirect_to root_url if @visit.nil?
    end

    def admin_user
      @visit = current_user.visits.find_by(id: params[:id])
      redirect_to root_url unless current_user.admin?
    end
	
    def set_visit_fees ( visit )
      if !visit.proc_code.blank? 
	      p = Procedure.find_by(code: visit.proc_code) 
	      visit.fee = p.cost
      end
      if !visit.proc_code2.blank? 
	      p = Procedure.find_by(code: visit.proc_code2) 
	      visit.fee2 = p.cost
      end  
      if !visit.proc_code3.blank? 
	      p = Procedure.find_by(code: visit.proc_code3) 
	      visit.fee3 = p.cost
      end  
      if !visit.proc_code4.blank? 
	      p = Procedure.find_by(code: visit.proc_code4) 
	      visit.fee4 = p.cost
      end  
    end

  def build_visit_form ( pat, visit )
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
    pdf.draw_text "Provider: Dr. #{current_doctor.lname}", :at => [5.mm,210.mm]
    pdf.draw_text "Family Doctor: Dr. #{current_doctor.lname}", :at => [5.mm,200.mm]
  
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
  end


end
