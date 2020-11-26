module PatientsHelper

# Returns the current patient (if any).
  def current_patient
    @current_patient ||= Patient.find(session[:patient_id] ) rescue nil
  end

# Returns true if the given doctor is the current one
  def current_patient?(patient)
    patient == current_patient
  end

# Remember current patient
  def set_pat_session ( id )
    session[:patient_id] = id
#    logger.debug "****** set_pat_session:  #{session[:patient_id]}"
  end

  def clear_pat_session
    session[:patient_id] = nil
  end

end
