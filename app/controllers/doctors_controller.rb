class DoctorsController < ApplicationController
       before_action :logged_in_user, only: [:index, :edit, :update]

  def new
    @doctor = Doctor.new
  end

  def index
          @doctors = Doctor.paginate(page: params[:page]) #, per_page: 40)
  end

  def find
      str = params[:findstr]
      @doctors = myfind(str)
      if @doctors.any?
         flash.now.alert = 'Found: '+ @doctors.size.to_s
               @doctors = @doctors.paginate(page: params[:page])
               render 'index'
      else
               render 'doctor_not_found'
      end
  end

  def show
    @doctor = Doctor.find(params[:id])
  end

  def create
     @doctor = Doctor.new(patient_params)
    if @doctor.save
       flash[:success] = "Doctor created"
       redirect_to @doctor
    else
       render 'new'
    end
  end  
	
end
