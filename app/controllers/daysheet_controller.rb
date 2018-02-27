class DaysheetController < ApplicationController
	
  def index
      date = params[:date] || Date.today
      @daysheet = Visit.where("date(entry_ts) = ?", date)
      if @daysheet.any?
         @daysheet = @daysheet.paginate(page: params[:page])
      else
	 flash.now[:warning] = 'No visits were found for date ' + date.inspect 
      end
      render 'index'
  end

  def set_doctor 
      if params[:doc_id]
	 session[:doc_id] = params[:doc_id]
	 doc = Doctor.find(params[:doc_id]) || Doctor.new()
	 flash[:info] = "Current Doctor set to Dr. #{doc.lname}"
	 redirect_back(fallback_location: daysheet_index_path)
#	 redirect_to daysheet_index_path
      else
	 render '_set_doctor'
      end
  end

end
