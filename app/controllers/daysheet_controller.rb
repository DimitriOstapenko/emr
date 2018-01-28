class DaysheetController < ApplicationController
	
  def index
      date = params[:date] || Date.today
      @daysheet = Visit.where("date(entry_ts) = ?", date)
      if @daysheet.any?
#         if @daysheet.size == 1
#               @visit = @daysheet.first
#	       redirect_to patient_visit_path(@visit.patient_id, @visit.id)
#         else
               @daysheet = @daysheet.paginate(page: params[:page])
               render 'index'
#         end
      else
	 flash.now[:error] = 'No visits were found for date ' + date.inspect 
         render 'shared/empty_page'
      end
  end

end
