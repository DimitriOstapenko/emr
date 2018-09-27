class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ApplicationHelper
  include SessionsHelper
  include DaysheetHelper
  helper_method :hcp_procedure?

  add_flash_types :info, :warning

#  layout :choose_layout

#  def initialize
#    WillPaginate.per_page = 10 if device_type == 'desktop'
#  end

  private

# Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        redirect_to login_url, flash: {warning: "Please log in."} 
      end
    end

# alert if current_doctor is not set
   def current_doctor_set
     unless current_doctor
       store_location
       flash.keep[:warning] = "Please set doctor for this shift"
       redirect_to set_doctor_url if device_type == 'mobile'
     end
   end

# Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user && current_user.admin?
    end

# Is procedure OHIP covered?
  def hcp_procedure?(proc_code)
    Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
  end

# Returns the current doctor (if any).
  def current_doctor
    @current_doctor ||= Doctor.find_by(id: session[:doc_id] )
  end

  def choose_layout
    if current_user.admin?
       "admin"
    else
       "application"
    end
  end
end
  
