class DaysheetController < ApplicationController
	
	helper_method :sort_column, :sort_direction

	before_action :logged_in_user
        before_action :current_doctor_set
	
  def index
      @date = Date.parse(params[:date]) rescue nil
      store_location
      if @date.present?
        @daysheet = Visit.where("date(entry_ts) = ?", @date) 
      else 
        @daysheet = Visit.where(status: [ARRIVED,WITH_DOCTOR,READY,ERROR] ).or(Visit.where('date(entry_ts) = ? AND status<?', Date.today, CANCELLED))
	@date = Date.today
      end
      
      @daysheet = @daysheet.where(doc_id: current_doctor.id) if current_user.doctor?
      @docs_visits = Visit.where("date(entry_ts) = ?",@date).group('doc_id').reorder('').size
      @docs = Doctor.find(@docs_visits.keys) rescue []
	 
      doc = Doctor.find(params[:doc_id]) rescue nil
      if doc.present?
	 @daysheet = @daysheet.where(doc_id: doc.id)
	 flashmsg = "Daysheet for Dr. #{doc.lname} : #{@daysheet.count} visits "
      else
	 flashmsg = "#{@daysheet.count}  #{'visit'.pluralize(@daysheet.count)}"
      end

      @insured_svcs = @cash_svcs = @ifh_svcs = @total_cash = 0
      @daysheet.map{|v| @insured_svcs += v.total_insured_services}
      @daysheet.map{|v| @cash_svcs += v.total_cash_services}
      @daysheet.map{|v| @total_cash += v.total_cash}
      @daysheet.map{|v| @ifh_svcs += v.total_ifh_services}
      ins_str = @insured_svcs>0 ? ", #{@insured_svcs} insured #{'service'.pluralize(@insured_svcs)}" : ''
      csh_str = @cash_svcs>0 ? ", #{@cash_svcs} cash #{'service'.pluralize(@cash_svcs)} (#{sprintf('$%.2f',@total_cash)})" : ''
      ifh_str = @ifh_svcs>0 ? ", #{@ifh_svcs} IFH #{'service'.pluralize(@ifh_svcs)}" : ''

      if @daysheet.any?
	 @daysheet = @daysheet.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
	 flash.now[:info] = "#{flashmsg}#{ins_str}#{csh_str}#{ifh_str}"
      else  
	 flash.now[:info] = 'No visits were found for ' + @date.strftime("%B %d, %Y") 
	 render  inline: '', layout: true
      end
  end

  private

  def sort_column
          Visit.column_names.include?(params[:sort]) ? params[:sort] : "status"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
