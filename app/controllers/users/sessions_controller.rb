class Users::SessionsController < Devise::SessionsController
  respond_to :html, :js

  def destroy
    patient = session[:patient_id] if current_user.patient?
    super
    session[:patient_id] = patient if patient 
  end
end
