class VisitsController < ApplicationController

  include My::Forms

	before_action :logged_in_user #, only: [:create, :destroy, :index]
        before_action :current_doctor_set #, only: [:create, :visitform, :receipt]  
	before_action :admin_user, only: :destroy

  def index (defdate = Date.today )
    date = params[:date] || defdate
    @patient = Patient.find(params[:patient_id])
    if @patient.visits.any?
	   @visits = @patient.visits.paginate(page: params[:page])
	   render 'index'
      else
	   flash.now[:warning] = "No visits found for date: #{date.inspect}" 
	   render  body: nil
    end
  end

  def new
        @patient = Patient.find(params[:patient_id])
        @visit = @patient.visits.new
        current_doctor_set
#        redirect_back(fallback_location: @visit ) #new_patient_visit_path
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @visit = @patient.visits.build(visit_params)
    @visit.entry_ts = DateTime.now
    @visit.entry_by = current_user.name

    if @visit.doc_id != current_doctor.id
	 set_doc_session ( @visit.doc_id )
	 flash[:info] = "Current Doctor set to Dr. #{@visit.doctor.lname}"
    end

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

  def show
     @visit = Visit.find(params[:id])
  end

  def edit
     @visit = Visit.find(params[:id])
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
	      flash.now[:warning] = "No visits found for date: #{date.inspect}" 
#           redirect_to visits_url
	    render "no_daysheet_found"
      end
  end

# Generate visit form in PDF
  def visitform
        @visit = Visit.find(params[:id])
	@patient = Patient.find(@visit.patient_id)
        pdf = build_visit_form( @patient, @visit )

        send_data pdf.render,
          filename: "form_#{@patient.full_name}",
          type: 'application/pdf',
          disposition: 'inline'
  end  

# Generate PDF receipt for 3RD party services  
  def receipt
        @visit = Visit.find(params[:id])
	@patient = Patient.find(@visit.patient_id)
        pdf = build_receipt( @patient, @visit )

        send_data pdf.render,
          filename: "receipt_#{@patient.full_name}",
          type: 'application/pdf',
          disposition: 'inline'

#    render inline: '', layout: true
  end

# Generate PDF invoice for 3-rd party service
  def invoice
	@visit = Visit.find(params[:id])
        @patient = Patient.find(@visit.patient_id)
        pdf = build_invoice( @patient, @visit )

        send_data pdf.render,
          filename: "invoice_#{@patient.full_name}",
          type: 'application/pdf',
          disposition: 'inline'
  end

  private

    def visit_params
      params.require(:visit).permit(:vis_type, :diag_code, :patient_id, :doc_id, #:services,
				    :proc_code, :proc_code2, :proc_code3, :proc_code4,
				    :units, :units2, :units3, :units4, 
				    :fee, :fee2, :fee3, :fee4,
				    :bil_type, :bil_type2, :bil_type3, :bil_type4, 
				    :reason, :notes, :entry_ts, :status, :duration, :entry_by )
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

end
