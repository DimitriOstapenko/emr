class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper
  include DaysheetHelper
  helper_method :hcp_procedure?

#  def initialize
#    WillPaginate.per_page = 10 if device_type == 'desktop'
#  end

  private

# Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

# alert if current_doctor is not set
   def current_doctor_set
     flash.now[:danger] = "Please set doctor for this shift" unless current_doctor
   end

# Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user && current_user.admin?
    end

end

# Is procedure OHIP covered?
  def hcp_procedure?(proc_code)
    Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
  end

# Returns the current doctor (if any).
  def current_doctor
    @current_doctor ||= Doctor.find_by(id: session[:doc_id] )
  end
  
