class DoctorsController < ApplicationController
       
	before_action :set_doctor, only: [:show, :edit, :update, :destroy]
	before_action :logged_in_user #, only: [:index, :edit, :update]
	before_action :admin_or_staff_user
	before_action :admin_user, only: :destroy

  def new
    @doctor = Doctor.new
  end

  def index
    @doctors = Doctor.paginate(page: params[:page]) #, per_page: 40)
  end

  def find
      str = params[:findstr].strip
      @docs = myfind(str)
      if @docs.any?
	 flash.now[:info] = "Found #{@docs.count} #{'doctor'.pluralize(@docs.count)} matching string #{str.inspect}"
      else
	 @docs = Doctor.all
	 flash[:danger] = "No doctors found" 
      end
      @doctors = @docs.paginate(page: params[:page])
      render 'index'
  end

  def show
  end
  
  def edit
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

  def destroy
    @doctor.destroy
    flash[:success] = "Doctor deleted"
    redirect_to doctors_url, page: params[:page]
  end

  def update
    if @doctor.update(doctor_params)
      flash[:success] = "Profile updated"
      redirect_to doctors_path
    else
      render 'edit'
    end
  end

# Invite doctor to register  
  def invite_to_register
    @doctor = Doctor.find(params[:id])
    if @doctor.present? && @doctor.email.present?
      @user = @doctor.user 
      @user ||= User.create( email: @doctor.email, role: :doctor, invited_by: current_user.name, password: Time.now, doctor_id: @doctor.id, patient_id: Patient.first.id ) 
      UserMailer.invite_doctor(@user).deliver_now
      msg =  "Doctor '#{@doctor.lname}' was invited to complete registration"
    else
      msg = "Doctor was not found or email is missing"
    end

    flash[:info] = msg
    redirect_to doctors_path
  end

private
  def doctor_params
	  params.require(:doctor).permit(:lname, :fname, :provider_no, :group_no, :cpso_num, :wsib_num, :specialty, :district,
					 :bills, :address, :city, :prov, :postal, :phone, :fax, :mobile, :email, :licence_no,
					 :accepts_new_patients, :note, :office, :provider_no, :group_no,  :percent_deduction, :billing_format )
  end

  # Find doctor by last name or provider number, depending on input format
  def myfind (str)
	  if str.match(/^[[:digit:]]{,6}$/)
          Doctor.where("provider_no like ?", "%#{str}%")
        elsif str.match(/^[[:graph:]]+$/)
		Doctor.where("lower(lname) like ?", "%#{str.downcase}%")
        else
          []
        end
  end

  def set_doctor
      @doctor = Doctor.find(params[:id])
  end
 
	
end
