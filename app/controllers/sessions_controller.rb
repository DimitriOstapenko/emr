class SessionsController < ApplicationController

  def create_
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

  def destroy_
    log_out if logged_in?
    redirect_to root_url
  end

end
