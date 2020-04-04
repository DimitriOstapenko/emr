class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ApplicationHelper
  include SessionsHelper
  include DoctorsHelper
  helper_method :hcp_procedure?

  add_flash_types :info, :warning
  before_action :configure_permitted_parameters, if: :devise_controller?

#  def initialize
#    WillPaginate.per_page = 10 if device_type == 'desktop'
#  end

  private

# after devise sign-in
  def after_sign_in_path_for(resource)
    if current_user && current_user.patient?
      if current_user.new_patient?
         edit_patient_path(current_user.patient)
      else
         patient_path(current_user.patient)
      end
    else
      doc = Doctor.find_by(provider_no: '015539')
      session[:doc_id] = doc.id
      stored_location_for(resource) || daysheet_path
    end
  end

# Confirms a logged-in user.
    def logged_in_user
      redirect_to new_user_session_path unless current_user
    end

# Patient user, but patient_id is missing or wrong (does not belong to this patient)
   def verify_patient
     return unless current_user && current_user.patient?
     redirect_to root_path if current_user.patient_id.blank? 
     pat_id = params[:patient_id] || params[:id] rescue nil
     redirect_back fallback_location: patient_path(current_user.patient_id), warning: "You don't have the right to use this operation" unless (current_user.patient_id.to_s == pat_id)
   end

# alert if current_doctor is not set
   def current_doctor_set
     unless current_doctor.present? 
       store_location
       flash.now[:warning] = "Please set doctor for this shift"
       redirect_to set_doctor_url if device_type == 'mobile'
     end
   end

# Confirms an admin user.
  def admin_user
    redirect_back fallback_location: root_path, warning: "This operation is reserved to admin users only" unless current_user && current_user.admin?
  end

# Confirms staff user  
  def staff_user
     redirect_back fallback_location: root_path, warning: "This operation is reserved for staff users only" unless current_user && current_user.staff?
  end

# Confirms admin or staff user  
  def admin_or_staff_user
    redirect_back fallback_location: root_path, warning: "This operation is reserved to staff and admins only" unless current_user && (current_user.admin? || current_user.staff?)
  end    

# Confirms patient user
  def patient_user
    redirect_back fallback_location: root_path, warning: "This operation is reserved to patients only" unless current_user && current_user.patient? 
  end    

# Confirms non-patient user
  def non_patient_user
    redirect_to patient_path(current_user.patient), warning: "You don't have the right to use this operation" if current_user && current_user.patient? 
  end    

# Confirms the correct user.
    def correct_user
      @user = User.find(params[:id]) rescue nil
      redirect_back fallback_location: root_path, warning: "You have to be logged in"  unless (@user && current_user)
      redirect_back fallback_location: root_path, warning: "You don't have the right to use this operation"  unless (current_user?(@user) || current_user.admin?)
    end

# Is procedure OHIP covered?
  def hcp_procedure?(proc_code)
    Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
  end

  def choose_layout
    if current_user.admin?
       "admin"
    else
       "application"
    end
  end

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:ohip_num, :ohip_ver, :email, :role, :password, :password_confirmation)}
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:ohip_num, :ohip_ver, :email, :role, :password, :password_confirmation, :current_password )}
  end

end
  
