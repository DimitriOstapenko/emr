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
	 flash[:info] = 'Current Doctor set' 
	 redirect_to request.referrer
      else
	 render '_set_doctor'
      end
  end

end
