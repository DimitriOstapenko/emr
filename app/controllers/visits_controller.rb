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
	

end
