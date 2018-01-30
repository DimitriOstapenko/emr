class UsersController < ApplicationController
 
      	before_action :logged_in_user, only: [:index, :edit, :update]
  	before_action :correct_user,   only: [:edit, :update]
  	before_action :admin_user,     only: [:edit, :destroy]

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
     #  log_in @user
      flash[:success] = "User #{@user.name} created"
     # redirect_to @user
       redirect_to users_url
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
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :admin)
    end

# Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless (current_user?(@user) || current_user.admin?)
    end

end
