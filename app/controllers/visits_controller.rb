class VisitsController < ApplicationController

	before_action :logged_in_user, only: [:create, :destroy]
#	before_action :correct_user,   only: :destroy
	before_action :admin_user,   only: :destroy

  def create
    @visit = current_user.visits.build(visit_params)
    if @visit.save
      flash[:success] = "Visit created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @visit.destroy
    flash[:success] = "Visit deleted"
    redirect_to request.referrer || root_url
  end

  def index
     @visits = Visit.paginate(page: params[:page]) #, per_page: 40)
  end

  def show
     @visit = Visit.find(params[:id])
     @patient = Patient.find(@visit.patient_id)
     @doctor = Doctor.find(@visit.doc_id)
  end

  def daysheet
      date = params[:date]
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
      params.require(:visit).permit(:notes,:date,:diag_code,:proc_code,:patient_id,:doc_id)
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
