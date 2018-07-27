class ReportsController < ApplicationController
        include My::Forms
	
	helper_method :sort_column, :sort_direction

	before_action :logged_in_user #, only: [:index, :edit, :update]
	before_action :admin_user, only: :destroy

  def index
    store_location

    @reports = Report.paginate(page: params[:page])
    flash.now[:info] = "Showing all reports (#{@reports.count})"
  end

  def find
      str = params[:findstr].strip
      @reports = myfind(str)
      if @reports.any?
         @reports = @reports.paginate(page: params[:page])
	 flash.now[:info] = "Found: #{@reports.count} #{'report'.pluralize(@reports.count)}"
      else
         @reports = Report.new
         @reports = Report.paginate(page: params[:page])
	 flash.now[:info] = "Report #{str.inspect} was not found"
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
    prefix = @report.doc_id || 'all'

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
    
    @report.name = "#{prefix}_#{Time.now.to_i}_#{@report.rtype}"
    @report.filename = @report.name+'.pdf'
    if @report.save
       flash.now[:success] = "Report created : #{@report.name.inspect}"
       redirect_to export_report_path(@report)
    else
       render 'new'
    end
  end
  
  def show
    @report = Report.find(params[:id]) 
    redirect_to reports_path unless @report
    @visits, @total, @insured, @uninsured = get_visits( @report )
    @visits = @visits.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page], per_page: 25)
  end

  def show_pdf
   @report = Report.find( params[:id] )

   send_file @report.filespec,
	     filename: @report.name,
             type: "application/pdf",
             disposition: :attachment
  end

# Generate PDF version of the report, save in reports directory
  def export
    @report = Report.find(params[:id])
    @visits, @total,@insured,@uninsured = get_visits( @report )
    pdf = build_report( @report,@visits )
    @report.update_attribute(:filename, @report.name+'.pdf')

    pdf.render_file @report.filespec
    send_data pdf.render,
          filename: "report_#{@report.name}",
          type: 'application/pdf',
          disposition: :attachment
  end

  def destroy
    @report = Report.find(params[:id]).destroy
    if @report.present?
      File.delete( @report.filespec ) rescue nil
      @report.destroy
      flash[:success] = "Report deleted"
    end

    redirect_to reports_url, page: params[:page]
  end

private
  def report_params
     params.require(:report).permit(:doc_id, :name, :rtype, :filespec, :sdate, :edate, :filename )
  end

  # Find report(s) by name or type, depending on input format
  def myfind (str)
        if str.match(/^[[:digit:]]$/)   	         # rtype
          Report.where(rtype: str)
        elsif str.match(/^[[:graph:]]+$/)                # name
	  doc = Doctor.where("lower(lname) like ? AND bills='t'", "%#{str.downcase}%")
	  doc_id = doc[0].id rescue 0
	  Report.where("doc_id = ?", doc_id) if !doc.nil?
        else
          []
        end
  end

  def get_visits (rep)
    insured = 0
    if rep.doc_id
	    visits = Visit.where(doc_id: rep.doc_id).where(entry_ts: (rep.sdate..rep.edate)).order(entry_ts: :asc)
	    total = Visit.where(doc_id: rep.doc_id).where(entry_ts: (rep.sdate..rep.edate)).sum("fee+fee2+fee3+fee4")
	    visits.each{|v| insured += v.total_insured_fees}
    else
	    visits = Visit.where(entry_ts: (rep.sdate..rep.edate)).order(entry_ts: :asc)
	    total = Visit.where(entry_ts: (rep.sdate..rep.edate)).sum("fee+fee2+fee3+fee4")
	    visits.each{|v| insured += v.total_insured_fees}
    end
    uninsured = total - insured
    return [visits, total, insured, uninsured]
  end

  def sort_column
          Visit.column_names.include?(params[:sort]) ? params[:sort] : "entry_ts"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
