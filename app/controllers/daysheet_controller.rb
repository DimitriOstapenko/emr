class DaysheetController < ApplicationController
	
  def index
      date = params[:date] || Date.today
      @daysheet = Visit.where("date(entry_ts) = ?", date)
      if @daysheet.any?
               @daysheet = @daysheet.paginate(page: params[:page])
               render 'index'
      else
	 flash.now[:warning] = 'No visits were found for date ' + date.inspect 
         render 'shared/empty_page'
      end
  end

end
