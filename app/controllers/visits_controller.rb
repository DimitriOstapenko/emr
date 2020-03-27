class VisitsController < ApplicationController

  include My::Forms
  include My::EDT

  helper_method :sort_column, :sort_direction

  before_action :logged_in_user 
  before_action :verify_patient
  before_action :admin_user, only: :destroy

# before_action :current_doctor_set #, only: [:create, :visitform, :receipt]  

  def index (defdate = Date.today )
    date = params[:date] || defdate
    @patient = Patient.find(current_user.patient_id)
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
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @visit = @patient.visits.build(visit_params)
    visits_that_day = @patient.visits.where('date(entry_ts)=?', @visit.entry_ts.to_date).where("status<>?", PAID) # Allow double visits for cash services (HC Deposit)
    if visits_that_day.any?
       flash[:warning] = "Only 1 visit is allowed per patient per day"
       redirect_to @patient
    else
      set_visit_fees ( @visit )
      if @visit.save
        @visit.update_attribute(:entry_by, current_user.name)
        @patient.update_attribute(:last_visit_date, @visit.entry_ts)
        doc = @visit.documents.create(:document => params[:visit][:document]) if params[:visit][:document].present?
        if doc.blank? || doc.errors.blank?
          flash[:success] = "Visit saved #{params[:entry_ts]} "
          redirect_to @patient
        else
          flash.now[:danger] =  doc.errors.full_messages.first rescue ''
          render 'new'
        end
      else 
        render 'new'
      end
    end
end

  def edit
     @patient = Patient.find(params[:patient_id])
     @visit = Visit.find(params[:id])
  end

  def update
    @visit = Visit.find(params[:id])
    @patient = Patient.find(@visit.patient_id)

    doc = @visit.documents.create(:document => params[:visit][:document]) if params[:visit][:document].present?
    if @visit.update_attributes(visit_params)
      @patient.update_attribute(:last_visit_date, @visit.entry_ts)
      if @visit.status == ARRIVED
        room = params[:visit][:room].to_i
        if room > 0 
           @visit.status =  WITH_DOCTOR 
	   Visit.where(status: WITH_DOCTOR).where(room: room).update_all("room=0, status=#{ASSESSED}")  
        end
      end
      
      set_visit_fees( @visit )
      @visit.save
      flash[:success] = "Visit updated"
      redirect_back(fallback_location: daysheet_url)

    else
      flash.now[:danger] =  doc.errors.full_messages.first rescue ''
      render 'edit'
    end
  end

# Add cash service to the visit  
  def addcash
    @visit = Visit.find(params[:id])
  end

# Add voice note to the visit
  def addvoicenote
    @visit = Visit.find(params[:id])
  end


  def destroy
    @visit = Visit.find(params[:id])
    @visit.destroy
    flash[:success] = "Visit deleted"
    redirect_back(fallback_location: daysheet_path)
  end

  def show
    @visit = Visit.find(params[:id])
    @patient = @visit.pat
    @doctor = @visit.doctor
  end

# Send claim to Cab.md  
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
        @pdf = build_visit_form( @patient, @visit )

        respond_to do |format|
          format.html do
            send_data @pdf.render,
            filename: "form_#{@patient.full_name}",
            type: 'application/pdf',
            disposition: 'inline'
          end
	  format.js { @pdf.render_file File.join(Rails.root, 'public', 'uploads', "visitform.pdf") }
	end
  end  

# Generate PDF receipt for 3RD party services  
  def receipt
        @visit = Visit.find(params[:id])
	@patient = Patient.find(@visit.patient_id)
        @pdf = build_visit_receipt( @patient, @visit )

        respond_to do |format|
          format.html do
          send_data @pdf.render,
            filename: "receipt_#{@patient.full_name}",
            type: 'application/pdf',
            disposition: 'inline'
	  end
	  format.js { @pdf.render_file File.join(Rails.root, 'public', 'uploads', "receipt.pdf") }
	end
  end

  # List of unpaid visits this year, until the end of the last paid cycle  
  def unpaid_visits
    v = Visit.where(status: BILLED).where("entry_ts >?", Date.today.beginning_of_year).where('entry_ts<?', last_paid_visit_date)
    if v.any?
	@visits = v.reorder(sort_column + ' ' + sort_direction, "entry_ts desc").paginate(page: params[:page])
        flash.now[:info] = "Visits billed, but not marked as \"Paid\" this year: #{@visits.count}. IFH visits need to be updated manually after payment is received."
      else
        @visits = Visit.all.reorder(sort_column + ' ' + sort_direction, "entry_ts desc").paginate(page: params[:page])
        flash.now[:warning] = "No unpaid visits found for this year, excluding current billing cycle"
    end
    render 'index'
  end

  private

    def visit_params
      params.require(:visit).permit(:vis_type, :diag_code, :patient_id, :doc_id, #:services,
				    :proc_code, :proc_code2, :proc_code3, :proc_code4,
				    :units, :units2, :units3, :units4, 
				    :fee, :fee2, :fee3, :fee4,
				    :bil_type, :bil_type2, :bil_type3, :bil_type4, 
				    :reason, :notes, :entry_ts, :status, :duration, 
				    :entry_by, :provider_id, :temp, :bp, :pulse, :weight, :export_file, 
				    :billing_ref, :document, :room, :pat_type, :hin_num )
    end      

    def set_visit_fees ( visit )
      visit.fee = visit.fee2 = visit.fee3 = visit.fee4 = 0.0
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
    
    def sort_column
        Visit.column_names.include?(params[:sort]) ? params[:sort] : "entry_ts"
    end

    def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

end
