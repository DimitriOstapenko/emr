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
      @docs = myfind(str)
      if @docs.any?
         flash.now.alert = "Found: #{@docs.size} doctors"
      else
	 @docs = Doctor.all
	 flash[:error] = "No doctors found" 
      end
      @doctors = @docs.paginate(page: params[:page])
      render 'index'
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
					 :note, :office, :provider_no, :group_no, :specialty, :email, :doc_code )
  end

  # Find doctor by last name or provider number, depending on input format
  def myfind (str)
	  if str.match(/^[[:digit:]]{,6}$/)
          Doctor.where("provider_no like ?", "%#{str}%")
        elsif str.match(/^[[:graph:]]+$/)
          Doctor.where("lower(lname) like ?", "%#{str}%")
        else
          []
        end
  end
 
	
end
