class DaysheetController < ApplicationController
	
	helper_method :sort_column, :sort_direction

	before_action :logged_in_user
	before_action :non_patient_user
        before_action :current_doctor_set
	
  def index
      @date = Date.parse(params[:date]) rescue nil
      @sort = sort_column
      @direction = sort_direction

      if @date.present?
        @noerrorvisits = @daysheet = Visit.where("date(entry_ts) = ?", @date) 
      else 
        @daysheet = Visit.where(status: [ARRIVED,WITH_DOCTOR,ASSESSED,READY,ERROR] ).or(Visit.where('date(entry_ts) = ? AND status<?', Date.today, CANCELLED))
	@date = Date.today
	@noerrorvisits = @daysheet.where("date(entry_ts) = ?", @date)
      end
      
      @docs_visits = Visit.where("date(entry_ts) = ?",@date).group('doc_id').reorder('').size
      @docs = Doctor.find(@docs_visits.keys) rescue [] if @docs_visits.size > 1
	 
      if current_user.doctor?
         @noerrorvisits = @daysheet = @daysheet.where(doc_id: current_doctor.id)
	 flashmsg = "#{@noerrorvisits.count}  #{'visit'.pluralize(@noerrorvisits.count)}"
      elsif params[:doc_id].present?
	 doc = Doctor.find(params[:doc_id]) rescue nil
	 @noerrorvisits = @daysheet = @daysheet.where(doc_id: doc.id)
	 flashmsg = "Daysheet for Dr. #{doc.lname} : #{@daysheet.count} #{'visit'.pluralize(@daysheet.count)}"
      else
	 flashmsg = "#{@noerrorvisits.count}  #{'visit'.pluralize(@noerrorvisits.count)}"
      end

      @insured_svcs = @cash_svcs = @ifh_svcs = @total_cash = 0
      @noerrorvisits.map{|v| @insured_svcs += v.total_insured_services}
      @noerrorvisits.map{|v| @cash_svcs += v.total_cash_services}
      @noerrorvisits.map{|v| @total_cash += v.total_cash}
      @noerrorvisits.map{|v| @ifh_svcs += v.total_ifh_services}
      ins_str = @insured_svcs>0 ? ", #{@insured_svcs} insured #{'service'.pluralize(@insured_svcs)}" : ''
      csh_str = @cash_svcs>0 ? ", #{@cash_svcs} cash #{'service'.pluralize(@cash_svcs)} (#{sprintf('$%.2f',@total_cash)})" : ''
      ifh_str = @ifh_svcs>0 ? ", #{@ifh_svcs} IFH #{'service'.pluralize(@ifh_svcs)}" : ''

      if @daysheet.any?
	 @daysheet = @daysheet.reorder(sort_column + ' ' + sort_direction, "entry_ts desc").paginate(page: params[:page])
         hideold = helpers.link_to 'Hide Old', daysheet_path(:date => Date.today) if @date == Date.today
         flash.now[:info] = "#{flashmsg}#{ins_str}#{csh_str}#{ifh_str} &nbsp;| #{hideold} | Please call self-registered patients within an hour".html_safe
      else  
	 flash.now[:info] = 'No visits were found for ' + @date.strftime("%B %d, %Y") 
	 render  inline: '', layout: true
      end
  end

  def set_doctor
      doc_id = params[:doc_id]
      if doc_id
        store_location
        set_doc_session( doc_id )
        doc = Doctor.find( doc_id ) || Doctor.new()
        flash[:success] = "Current Doctor is set to Dr. #{doc.lname}"
        redirect_back_or( daysheet_path )
      else
        render '_set_doctor'
      end
  end


  private

  def sort_column
          Visit.column_names.include?(params[:sort]) ? params[:sort] : "entry_ts"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
