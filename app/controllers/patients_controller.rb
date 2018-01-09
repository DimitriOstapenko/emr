class PatientsController < ApplicationController

	before_action :logged_in_user, only: [:index, :edit, :update]

  def index
       if params[:findbox]
	 last_name = params[:findbox][:findstr]
         @patients = Patient.cifind_by('lname', last_name) 
	 if @patients.any?
	    flash.alert = 'Found: '+ @patients.size.to_s
	    if @patients.size == 1
	       @patient = @patients.first
	       redirect_to @patient
	    else
	       render 'found_patients'
            end
	 else
	    flash[:error] = 'Patient ' + last_name.inspect + ' was not found.'
            redirect_to patients_url
	 end
      else
	  @patients = Patient.paginate(page: params[:page]) #, per_page: 40)
      end
  end

  def show
    @patient = Patient.find(params[:id])
    @visits = @patient.visits.paginate(page: params[:page])
  end

  def new
    @patient = Patient.new
  end

  def create
     @patient = Patient.new(patient_params)
    if @patient.save
#     log_in @user
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
    if @patient.update_attributes(patient_params)
      flash[:success] = "Profile updated"
      redirect_to @patient
    else
      render 'edit'
    end
  end

private
  def patient_params
	  params.require(:patient).permit(:lname, :fname, :dob, :sex, :ohip_num, :phone, :full_name )
  end
	
end
