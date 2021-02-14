class UsersController < ApplicationController
 
      	before_action :logged_in_user, except: [:lookup]  #, except: :resend_activation_link
  	before_action :correct_user, only: [:show, :edit, :update]
  	before_action :admin_user, except: [:show, :edit, :update, :lookup]   #,     only: [:index, :new, :create, :destroy]

        helper_method :sort_column, :sort_direction

  def index
    keyword = params[:findstr]
    if keyword
       @users = User.search(keyword)
    else
       @users = User.all
    end
    @users = @users.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) 
    flash[:info] = "#{@users.count} users found" if keyword
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
#    logger.debug("**** new called")
  end

  def create
#    logger.debug("**** create.called")
    @user = User.new(user_params)
    if @user.save
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
    if @user.update(user_params)
#      sign_out
#      sign_in(@user)
      flash[:success] = "User profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

   def switch_to
    user = User.find(params[:id])
    set_doc_session(user.doctor_id) if user.doctor?
    sign_in(:user, user)
    flash.now[:info] = 'Switched to new user'

    if user.patient?
      redirect_to patient_path(user.patient_id) 
    else
      redirect_to root_url
    end
  end


private

    def user_params
      params.require(:user).permit(:ohip_num, :ohip_ver, :email, :password, :password_confirmation, :role, :patient_id, :doctor_id, :invited_by, :dob, :first_visit_reason )
    end

    def sort_column
        User.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

end
