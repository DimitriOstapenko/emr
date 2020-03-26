module DoctorsHelper

# Returns the current doctor (if any).
  def current_doctor
    @current_doctor ||= Doctor.find(session[:doc_id] ) rescue nil
  end

# Returns true if the given docttor is the current
  def current_doctor?(doctor)
    doctor == current_doctor
  end

# Remember current doctor
  def set_doc_session ( id )
    session[:doc_id] = id
  end

end
