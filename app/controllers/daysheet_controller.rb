class DaysheetController < ApplicationController
	
	helper_method :sort_column, :sort_direction

	before_action :logged_in_user
#        before_action :admin_user, only: :destroy
	
  def index
      date = params[:date] || Date.today
      
      @docs_visits = Visit.where("date(entry_ts) = ?",date).group('doc_id').reorder('').size
      @docs = Doctor.find(@docs_visits.keys) rescue []
      if params[:doc_id]
         @daysheet = Visit.where("date(entry_ts) = ?", date).where(doc_id: params[:doc_id])
         d = Doctor.find(params[:doc_id])
         doctor = "Dr. #{d.lname}" if !d.nil?
      else
         @daysheet = Visit.where("date(entry_ts) = ?", date)
      end

      @totalfee = @totalinsured = @totalcash = 0
      @daysheet.map{|v| @totalfee += v.total_fee}
      @daysheet.map{|v| @totalcash += v.total_cash}
      @daysheet.map{|v| @totalinsured += v.total_insured_fees}
      if @daysheet.any?
#         @daysheet = @daysheet.paginate(page: params[:page])
	 @daysheet = @daysheet.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
	 flash.now[:info] = "Daysheet for #{date} : #{@daysheet.count} visits. Total fee: #{sprintf("$%.2f",@totalfee)} Insured: #{sprintf("$%.2f",@totalinsured)}; Cash: #{sprintf("$%.2f",@totalcash)}."
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
	 redirect_back_or( daysheet_url )
      else
	 render '_set_doctor'
      end
  end


  def sort_column
          Visit.column_names.include?(params[:sort]) ? params[:sort] : "entry_ts"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
