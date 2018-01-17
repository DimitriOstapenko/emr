class DoctorsController < ApplicationController
       
	before_action :logged_in_user, only: [:index, :edit, :update]
	before_action :admin_user,   only: :destroy

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
  
  def edit
    @doctor = Doctor.find(params[:id])
  end

  def create
     @doctor = Doctor.new(doctor_params)
    if @doctor.save
       flash[:success] = "Doctor created"
       redirect_to @doctor
    else
       render 'new'
    end
  end  

private
  def doctor_params
	  params.require(:doctor).permit(:lname, :fname, :full_name, :cpso_num, :billing_num, :service, :ph_type,
					 :district, :bills, :addr, :city, :prov, :postal, :phone, :mobile, :licence_no,
					 :note, :office, :provider_no, :group_no, :specialty, :email )
  end
 
	
end
