class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper
  include DaysheetHelper

  private

# Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

# confirms current_doctor set
   def current_doctor_set
	 unless current_doctor
	   store_location
	   flash[:danger] = "Please set current doctor"
	   redirect_to set_doctor_url
	 end
   end

# Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
