module DoctorsHelper

# Returns the current doctor (if any).
  def current_doctor
    @current_doctor ||= Doctor.find(session[:doc_id] ) rescue nil
  end

# Returns true if the given doctor is the current one
  def current_doctor?(doctor)
    doctor == current_doctor
  end

# Remember current doctor
  def set_doc_session ( id )
    session[:doc_id] = id
#    logger.debug "****** set_doc_session:  #{session[:doc_id]}"
  end


end
