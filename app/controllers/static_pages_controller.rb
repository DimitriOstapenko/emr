class StaticPagesController < ApplicationController

  include PatientsHelper

  def home
#    clear_pat_session
    
    if current_user && current_user.patient
      redirect_to current_user.patient 
    elsif current_patient && current_patient.user && current_patient.user.confirmed_at
      redirect_to new_user_session_url
    end

#    flash[:info] = "pat #{current_patient.inspect}  user : #{current_user.inspect}"
  end

  def other_clinics
    render 'walkin_clinics_stoney_creek'
  end

  def other_doctors
    render 'other_doctors'
  end

  def help
  end

  def about
  end

  def contact
  end
  
  def news
  end

  def terms
  end

  def privacy
  end
end
