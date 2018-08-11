class VisitsController < ApplicationController

  include My::Forms

	before_action :logged_in_user #, only: [:create, :destroy, :index]
##        before_action :current_doctor_set #, only: [:create, :visitform, :receipt]  
#	before_action :admin_user, only: :destroy

  def index (defdate = Date.today )
    date = params[:date] || defdate
    @patient = Patient.find(params[:patient_id])
    if @patient.visits.any?
	   @visits = @patient.visits.paginate(page: params[:page])
	   render 'index'
      else
	   flash.now[:warning] = "No visits found for date: #{date.inspect}" 
	   render  inline: '', layout: true
    end
  end

  def new
        @patient = Patient.find(params[:patient_id])
        @visit = @patient.visits.new
        @visit.entry_ts = Time.now.strftime("%Y-%m-%d at %H:%M")
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @visit = @patient.visits.build(visit_params)
    @visit.entry_by = current_user.name
    if @visit.entry_ts.present?
       @visit.entry_ts = Time.now if @visit.entry_ts > Date.tomorrow
    else
       @visit.entry_ts = Time.now
    end

    if current_doctor.blank? || @visit.doc_id != current_doctor.id
	 set_doc_session ( @visit.doc_id )
	 flash.now[:info] = "Current Doctor set to: Dr. #{@visit.doctor.lname}" if @visit.doctor.lname
    end

    set_visit_fees ( @visit )

    if @visit.save
      @patient.update_attribute(:last_visit_date, @visit.entry_ts)
      @visit.update_attribute(:status, READY) if @visit.status == PAID && @visit.hcp_services?  # Force to READY if there are ohip services
      flash[:success] = "Visit saved! #{params[:entry_ts]} "
      redirect_to @patient
    else
      render 'new'
    end
  end

  def destroy
    @visit = Visit.find(params[:id])
    @visit.destroy
    flash[:success] = "Visit deleted"
#    redirect_to daysheet_path
    redirect_back(fallback_location: daysheet_path)
  end

  def show
     @visit = Visit.find(params[:id])
  end

   def sendclaim
       require 'net/http'
       require 'uri'

       @visit = Visit.find(params[:id])
       @patient = Patient.find(@visit.patient_id)
       @patient.fname = @patient.full_sex unless @patient.fname.present?
       @doctor = Doctor.find(@visit.doc_id)
       @xml = render_to_string "show.xml"

       uri = URI.parse(CABMDURL)
       http= Net::HTTP.new(uri.host,uri.port)
       http.use_ssl = true
       
       req = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/xml'})
       req.body = @xml

       res = http.request(req)
       @xmlhash = JSON.parse(res.body)
# {"success"=>true, "errors"=>[], "messages"=>[], "reference_id"=>"332933", "accounting_number"=>"0004MZ4Z"}
       
       if @xmlhash['success'] 
	  acc_num = @xmlhash['accounting_number']
          flash[:success] = "Claim #{acc_num} sent to cab.md " 
          @visit.update_attribute(:status, BILLED)
          @visit.update_attribute(:billing_ref, acc_num)
       else
	  errors = @xmlhash['errors']
	  messages = @xmlhash['messages']
	  flash[:danger] = "Error sending claim : #{@xmlhash}"
          @visit.update_attribute(:status, READY)
	  @visit.update_attribute(:billing_ref, errors.join(',')) if errors.present?
       end

       respond_to(:html)
       redirect_to patient_visit_path
  end

  def edit
     @visit = Visit.find(params[:id])
  end

  def update
    @visit = Visit.find(params[:id])
    @patient = Patient.find(@visit.patient_id)
    if @visit.update_attributes(visit_params)
      @patient.last_visit_date = @visit.created_at
      @patient.save
      set_visit_fees( @visit )
      @visit.save
      flash[:success] = "Visit updated"
#     redirect_back(fallback_location: @patient)
#     redirect_to @patient
       redirect_back_or( @patient )
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
        pdf = build_visit_receipt( @patient, @visit )

        send_data pdf.render,
          filename: "receipt_#{@patient.full_name}",
          type: 'application/pdf',
          disposition: 'inline'

#    render inline: '', layout: true
  end

# Generate referral form for this visit
  def referralform
	@visit = Visit.find(params[:id])
        @patient = Patient.find(@visit.patient_id)
	pdf = build_referral_form( @patient, @visit )
        
	send_data pdf.render,
             filename: "referral_#{@patient.full_name}",
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
				    :reason, :notes, :entry_ts, :status, :duration, 
				    :entry_by, :provider_id, :temp, :bp, :pulse, :weight, :export_file, :billing_ref )
    end      

    def set_visit_fees ( visit )
      if !visit.proc_code.blank? 
	      p = Procedure.find_by(code: visit.proc_code) 
	      visit.fee = p.cost*visit.units rescue 0
      end
      if !visit.proc_code2.blank? 
	      p2 = Procedure.find_by(code: visit.proc_code2) 
	      visit.fee2 = p2.cost*visit.units2 rescue 0
      end  
      if !visit.proc_code3.blank? 
	      p3 = Procedure.find_by(code: visit.proc_code3) 
	      visit.fee3 = p3.cost*visit.units3 rescue 0
      end  
      if !visit.proc_code4.blank? 
	      p4 = Procedure.find_by(code: visit.proc_code4) 
	      visit.fee4 = p4.cost*visit.units4 rescue 0
      end  
    end

end
