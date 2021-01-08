class MyRegistrationsController < Devise::RegistrationsController

  respond_to :html, :js

# Go to login screen after registration  
#  def after_sign_up_path_for(resource)
   def after_inactive_sign_up_path_for(resource)    
      redirect_to new_user_session_path && return
  end

# Log in user after registration
  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    redirect_to patient_path(current_user.patient)
  end

  def after_update_path_for(resource)
    sign_in(resource)
    redirect_to patient_path(current_user.patient)
  end

end
