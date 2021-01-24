class Users::SessionsController < Devise::SessionsController
  respond_to :html, :js

  def destroy
    patient = session[:patient_id]
    super
#   session['warden.user.user.key'] = nil
    session[:patient_id] = patient
  end
end
