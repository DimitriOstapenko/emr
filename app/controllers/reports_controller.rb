 class ReportsController < ApplicationController
        include My::Forms
	require 'fileutils'

	helper_method :sort_column, :sort_direction
	before_action :logged_in_user, :non_patient_user
	before_action :admin_user, only: :destroy

  def index
    store_location

    if current_user.doctor?
      @reports = Report.where(doc_id: current_doctor.id).reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
    else 
      @reports = Report.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
    end
  end

  def new
    @report = Report.new
  end

  def create
    @report = Report.new(report_params)
    year = params[:date][:year]
    month  = params[:date][:month]
    prefix = @report.rtype + '_'
    prefix += @report.doc_id.to_s || 'all'
    sdate = @report.sdate.to_date rescue Date.today
    @doc  = Doctor.find(@report.doc_id)
    @visits_that_day = []

    case @report.timeframe
       	when 1   # date
		 @report.sdate = sdate
		 @report.edate = sdate + 24.hours 
    		 @visits_that_day = Visit.where("date(entry_ts)=? and doc_id=?", @report.sdate, @report.doc_id)
    		 if @visits_that_day.any?
                   unbilled = @visits_that_day.where("status=?", ARRIVED)
		   flash[:danger] = "Cannot create report before billing is finished. There are still #{unbilled.count} visits marked as ARRIVED in Day Sheet for doctor #{@doc.lname}" if unbilled.any?
		 else
	            flash[:danger] = "Dr. #{@doc.lname} didn't see any patients on #{@report.sdate}"
		 end
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
	  	 @report.edate = sdate + 100.years
	when 6   # Billing cycle - payment report
		 @report.sdate = Date.new(year.to_i,month.to_i) rescue Date.new(Time.now.year,Time.now.month)
		 @report.edate = 1.month.since(@report.sdate)
	else     # invalid
   	 	 flash.now[:danger] = "Invalid report timeframe: #{@report.timeframe}"
	end

    @report.name = "#{prefix}_#{@report.sdate.strftime("%Y%m%d")}_#{@report.timeframe}"
    @report.filename = @report.name+'.pdf'

# We will replace existing reports

    old_report = Report.find_by(filename: @report.filename)
    if old_report.present?
      File.delete( old_report.filespec ) rescue nil
      old_report.destroy
    end
    
       if flash[:danger]
	  redirect_to reports_path
       elsif @report.save
          flash.now[:success] = "Report created : #{@report.name.inspect}"
	  redirect_to export_report_path(@report)
#	  redirect_to reports_path
       else
	  flash.now[:danger] = @report.errors.full_messages.to_sentence
          render 'new'
       end
  end

  def show
    @report = Report.find(params[:id]) 
    redirect_to reports_path unless @report

    respond_to do |format|
      format.html { 
        send_file(@report.filespec,
             filename: @report.filename,
             type: "application/pdf",
             disposition: :inline) 
      }
      format.js 
    end

#   @visits, @total, @insured, @uninsured = get_visits( @report )
#   @visits = @visits.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page], per_page: 25)
  end

  def download
   @report = Report.find( params[:id] )

   if @report.present? && File.exists?(@report.filespec)
          send_file @report.filespec,
	     filename: @report.filename,
             type: "application/pdf",
             disposition: :attachment
   else
     flash.now[:danger] = "File #{@report.filename} was not found - regenerating" 
     redirect_to export_report_path(@report)
   end
  end

# Generate PDF version of the report, save in reports directory
  def export
    @report = Report.find(params[:id])
    if @report.rtype == SC_REPORT      # Submitted Claims Report
       @visits, @total, @insured, @uninsured = get_visits( @report )
       @pdf = build_sc_report( @report, @visits )
    elsif @report.rtype == PC_REPORT   # Paid Claims Report
       prov_no = @report.doctor.provider_no rescue 0
       @claims = Claim.joins(:services).where(provider_no: prov_no).where(date_paid: (@report.sdate..@report.edate)).reorder('').group('claims.id,services.svc_date').order('services.svc_date')
       @pdf = build_pc_report( @report, @claims )
    elsif @report.rtype == CS_REPORT  # Cash Report
       @visits, @cash = get_cash_visits( @report )
       @pdf = build_cs_report( @report, @visits )
    end

    @pdf.render_file @report.filespec
    redirect_to reports_path, alert: "New report created for Dr. #{@doc.lname}"
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

private
  def report_params
     params.require(:report).permit(:doc_id, :name, :rtype, :filespec, :sdate, :edate, :filename, :timeframe )
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

# get insured visits and totals  
  def get_visits (rep)
    insured = 0
    visits = Visit.where(entry_ts: (rep.sdate..rep.edate)).order(entry_ts: :asc)
    visits = visits.where(doc_id: rep.doc_id).where(entry_ts: (rep.sdate..rep.edate)).order(entry_ts: :asc) if rep.doc_id
    total = Visit.where(doc_id: rep.doc_id).where(entry_ts: (rep.sdate..rep.edate)).sum("fee+fee2+fee3+fee4")
    visits.each{|v| insured += v.total_insured_fees}
    uninsured = total - insured
    return [visits, total, insured, uninsured]
  end

  def get_cash_visits (rep)
    cash  = 0
    visits = Visit.where(entry_ts: (rep.sdate..rep.edate)).where('bil_type=4 OR bil_type2=4 OR bil_type3=4 OR bil_type4=4').order(entry_ts: :asc)
    visits = visits.where(doc_id: rep.doc_id).order(entry_ts: :asc) if rep.doc_id
    visits.each{|v| cash += v.total_cash}
    return [visits, cash]
  end

  def sort_column
          Report.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
