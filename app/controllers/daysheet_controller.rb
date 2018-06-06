class DaysheetController < ApplicationController
	
	before_action :logged_in_user
        before_action :admin_user, only: :destroy
	
  def index
      date = params[:date] || Date.today
      @daysheet = Visit.where("date(entry_ts) = ?", date)
      @totalfee = 0
      @daysheet.map{|v| @totalfee += v.total_fee}
      if @daysheet.any?
         @daysheet = @daysheet.paginate(page: params[:page])
	 flash.now[:info] = "Daysheet for #{date} (#{@daysheet.count} visits). Total fee: #{sprintf("$%.2f",@totalfee)}"
         render 'index'
      else
	 flash.now[:info] = 'No visits were found for date ' + date.inspect 
	 render  inline: '', layout: true
      end
  end

  def set_doctor 
      doc_id = params[:doc_id]
      id = params[:id]
      if doc_id
	 set_doc_session( doc_id )
	 doc = Doctor.find( doc_id ) || Doctor.new()
	 flash[:info] = "Current Doctor set to Dr. #{doc.lname}"
#	 redirect_back(fallback_location: daysheet_index_path)
	 redirect_back_or( patients_url )
      else
	 render '_set_doctor'
      end
  end

end
