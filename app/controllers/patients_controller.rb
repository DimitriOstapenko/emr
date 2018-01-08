class PatientsController < ApplicationController

	before_action :logged_in_user, only: [:index, :edit, :update]

  def index
    @patients = Patient.paginate(page: params[:page]) #, per_page: 40)
  end

  def show
    @patient = Patient.find(params[:id])
  end

  def new
    @patient = Patient.new
  end

  def create
  @patient = Patient.new(pat_params)
    if @patient.save
#      log_in @user
       flash[:success] = "Patient created"
       redirect_to @patient
    else
       render 'new'
    end	
  end

  def destroy
    Patient.find(params[:id]).destroy
    flash[:success] = "Patient deleted"
    redirect_to patients_url
  end

  def edit
    @patient = Patient.find(params[:id])
  end

  def update
    @patient = Patient.find(params[:id])
    if @patient.update_attributes(pat_params)
      flash[:success] = "Profile updated"
      redirect_to @patient
    else
      render 'edit'
    end
  end

private
  def pat_params
     params.require(:patient).permit(:lname, :fname, :dob, :sex, :ohip_num, :phone, :full_name) 
  end
	
end
