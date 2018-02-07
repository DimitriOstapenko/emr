module DaysheetHelper


# Returns the current doctor (if any).
  def current_doctor
    @current_doctor ||= Doctor.find_by(id: session[:doc_id] )
  end

end
