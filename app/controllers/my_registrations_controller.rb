class MyRegistrationsController < Devise::RegistrationsController

# Log in user after registration
  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)

#    redirect_to visits_path
    redirect_to patient_path(current_user.patient)
  end

end
