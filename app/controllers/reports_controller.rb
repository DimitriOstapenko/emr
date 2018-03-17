class ReportsController < ApplicationController

	before_action :logged_in_user, only: [:index, :edit, :update]
	before_action :admin_user, only: :destroy

  def index
    @reports = Report.paginate(page: params[:page])
    flash.now[:info] = "Showing all reports"
  end

  def find
      str = params[:findstr]
      @reports = myfind(str)
      if @reports.any?
         @reports = @reports.paginate(page: params[:page])
	 flash.now[:info] = "Found: #{@reports.count} #{'report'.pluralize(@reports.count)}"
      else
         @reports = Report.new
         @reports = Report.paginate(page: params[:page])
	 flash.now[:info] = 'Report #{str.inspect} was not found'
#	 redirect_to @reports 
      end
      render 'index'
  end

  def new
    @report = Report.new
  end

  def create
    @report = Report.new(report_params)
    year = params[:date][:year]
    month  = params[:date][:month]

    case @report.rtype
       	when 1   # date
		 @report.sdate = @report.sdate.to_date rescue Date.today 
		 @report.edate = @report.sdate.to_date + 24.hours 
	when 2   # mon
    	 	 @report.sdate = Date.new(year.to_i,month.to_i) 
    	  	 @report.edate = @report.sdate + 1.month - 1.day
	when 3   # year
    	  	 @report.sdate = Date.new(year.to_i) 
    	  	 @report.edate = @report.sdate + 1.year - 1.day 
	when 4   # range
		 @report.sdate = @report.sdate.to_date
		 @report.edate = @report.edate.to_date + 24.hours
	when 5   # all time
	  	 @report.sdate = Date.new(1950,01,01)
	  	 @report.edate = @report.sdate + 100.years
	else     # invalid
   	 	 flash.now[:danger] = "Invalid report type: #[@report.rtype]"
	end
    
    @report.name = @report.filespec = "#{Time.now.to_i}_#{@report.doc_id}_#{@report.rtype}"
    if @report.save
       flash.now[:success] = "Report created : #{@report.name.inspect}"
       redirect_to @report
    else
       render 'new'
    end
  end
  
  def show
    @report = Report.find(params[:id]) 
    redirect_to reports_path unless @report
    if @report.doc_id 
	    @visits = Visit.where(doc_id: @report.doc_id).where(entry_ts: (@report.sdate..@report.edate)).order(entry_ts: :asc) 
	    @total = Visit.where(doc_id: @report.doc_id).where(entry_ts: (@report.sdate..@report.edate)).sum("fee+fee2+fee3+fee4")
    else
	    @visits = Visit.where(entry_ts: (@report.sdate..@report.edate)).order(entry_ts: :asc)
	    @total = Visit.where(entry_ts: (@report.sdate..@report.edate)).sum("fee+fee2+fee3+fee4")
    end
    @visits = @visits.paginate(page: params[:page])
  end

  def destroy
    Report.find(params[:id]).destroy
    flash[:success] = "Report deleted"
    redirect_to reports_url, page: params[:page]
  end

private
  def report_params
     params.require(:report).permit(:doc_id, :name, :rtype, :filespec, :sdate, :edate )
  end

  # Find report(s) by name or type, depending on input format
  def myfind (str)
        if str.match(/^[[:digit:]]$/)               # rtype
          Report.where(rtype: str)
        elsif str.match(/^[[:graph:]]+$/)                # name
          Report.where("lower(name) like ?", "%#{str.downcase}%")
        else
          []
        end
  end

end
