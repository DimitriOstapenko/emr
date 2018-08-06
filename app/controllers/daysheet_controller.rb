class DaysheetController < ApplicationController
	
	helper_method :sort_column, :sort_direction

	before_action :logged_in_user
#        before_action :admin_user, only: :destroy
	
  def index
      @date = Date.parse(params[:date]) rescue nil
      store_location
      if @date.present?
        @daysheet = Visit.where("date(entry_ts) = ?", @date) 
      else 
        @daysheet = Visit.where(status: [ARRIVED,ASSESSED,READY,ERROR] )
	@date = Date.today
      end
      
      @docs_visits = Visit.where("date(entry_ts) = ?",@date).group('doc_id').reorder('').size
      @docs = Doctor.find(@docs_visits.keys) rescue []
	 
      if params[:doc_id]
         @daysheet = @daysheet.where(doc_id: params[:doc_id])
         d = Doctor.find(params[:doc_id])
         doctor = "Dr. #{d.lname}" if d.present?
         flashmsg = "Daysheet for #{doctor} : #{@daysheet.count} visits, "
      else
         flashmsg = "#{@daysheet.count}  #{'visit'.pluralize(@daysheet.count)},"
      end

      @insured_svcs = @cash_svcs = @ifh_svcs = @total_cash = 0
      @daysheet.map{|v| @insured_svcs += v.total_insured_services}
      @daysheet.map{|v| @cash_svcs += v.total_cash_services}
      @daysheet.map{|v| @total_cash += v.total_cash}
      @daysheet.map{|v| @ifh_svcs += v.total_ifh_services}
      if @daysheet.any?
	 @daysheet = @daysheet.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
	 flash.now[:info] = "#{flashmsg} #{@insured_svcs} insured #{'service'.pluralize(@insured_svcs)}; #{@cash_svcs} cash #{'service'.pluralize(@cash_svcs)} (#{sprintf('$%.2f',@total_cash)}); #{@ifh_svcs} IFH #{'service'.pluralize(@ifh_svcs)}"

#         render 'index'
      else  
	    flash.now[:info] = 'No visits were found for date ' + @date.inspect 
	    render  inline: '', layout: true
      end
      
  end

  def sort_column
          Visit.column_names.include?(params[:sort]) ? params[:sort] : "entry_ts"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
