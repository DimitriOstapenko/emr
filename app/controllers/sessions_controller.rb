class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
	log_in user
	params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        url = current_user.patient? ? 'patient_path(current_user.id)' : 'daysheet_url'
	redirect_back_or( eval url )
      else
	flash[:warning] = "Account not activated. Check your email for the activation link. "
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def switch_to
    if current_user.admin?
      user = User.find(params[:id])
      log_in user
    else 
      flash.now[:danger] = 'Invalid email/password combination'
    end
    redirect_to root_url
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def set_doctor
      doc_id = params[:doc_id]
      if doc_id
         store_location
	 set_doc_session( doc_id )
	 doc = Doctor.find( doc_id ) || Doctor.new()
	 flash[:info] = "Current Doctor is set to Dr. #{doc.lname}"
	 redirect_back_or( daysheet_path )
      else
	 render '_set_doctor'
      end
  end

end
