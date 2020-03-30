class UsersController < ApplicationController
 
      	before_action :logged_in_user #, except: :resend_activation_link
  	before_action :correct_user, only: [:show, :edit, :update]
  	before_action :admin_user, except: [:show, :edit, :update]   #,     only: [:index, :new, :create, :destroy]

  def index
    @users = User.paginate(page: params[:page]) 
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
#      @user.send_activation_email #!!! ?
      flash[:info] = "Please check your email to activate your account."
      redirect_back(fallback_location: root_url )
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      sign_out
      redirect_to root_url
    else
      render 'edit'
    end
  end

   def switch_to
    if current_user && current_user.admin?
      user = User.find(params[:id])
      if user.patient_id.present?
         sign_in(:user,user)
      else 
         flash[:info] = 'Patient is not attached to this user'
      end
    end

    if user.patient?
      redirect_to patient_path(user.patient_id) 
    else
      redirect_to root_url
    end
  end

  private

    def user_params
      params.require(:user).permit(:ohip_num, :ohip_ver, :email, :password, :password_confirmation, :role, :patient_id, :invited_by)
    end

# Confirms the correct user.
#    def correct_user
#      @user = User.find(params[:id]) rescue nil
#      redirect_to(root_url) unless (@user && current_user)
#      redirect_to(root_url) unless (current_user?(@user) || current_user.admin?)
#    end

end
