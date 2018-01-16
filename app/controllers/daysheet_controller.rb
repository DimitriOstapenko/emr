class DaysheetController < ApplicationController
	
  def index
      date = params[:date] || Date.today
      @daysheet = Visit.where("date(created_at) = ?", date)
      if @daysheet.any?
         if @daysheet.size == 1
               @visit = @daysheet.first
#	       render 'index'
	       redirect_to patient_visit_path(@visit.patient_id, @visit.id)
#               redirect_to @visit
         else
               @daysheet = @daysheet.paginate(page: params[:page])
               render 'index'
         end
      else
	 flash.now[:error] = 'No visits were found for date ' + date.inspect 
         render 'shared/empty_page'
      end
  end

end
