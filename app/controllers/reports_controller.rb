 class ReportsController < ApplicationController
        include My::Forms
	require 'fileutils'

	helper_method :sort_column, :sort_direction

	before_action :logged_in_user #, only: [:index, :edit, :update]
	before_action :admin_user, only: :destroy

  def index
    store_location

    @reports = Report.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
    flash.now[:info] = "Showing all reports (#{@reports.count})"
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
    @report.name = "#{prefix}_#{sdate.strftime("%Y%m%d")}_#{@report.timeframe}"
    @report.filename = @report.name+'.pdf'
    @visits_that_day = []

# We will replace existing reports

    old_report = Report.find_by(filename: @report.filename)
    if old_report.present?
      File.delete( old_report.filespec ) rescue nil
      old_report.destroy
    end

    case @report.timeframe
       	when 1   # date
		 @report.sdate = sdate
		 @report.edate = sdate + 24.hours 
    		 @visits_that_day = Visit.where("date(entry_ts)=? and doc_id=?", @report.sdate, @report.doc_id)
    		 if @visits_that_day.any?
                   unbilled = @visits_that_day.where("status=?", ARRIVED)
		   flash[:danger] = "Cannot create report before billing is finished. There are still #{unbilled.count} visits marked as ARRIVED in daysheet for doctor #{@doc.lname}" if unbilled.any?
		 else
	            flash[:danger] = "Dr. #{@doc.lname} didn't see any patients on #{@report.sdate}"
		 end
	when 2   # mon
    	 	 @report.sdate = Date.new(year.to_i,month.to_i) 
    	  	 @report.edate = sdate + 1.month - 1.day
	when 3   # year
    	  	 @report.sdate = Date.new(year.to_i) 
    	  	 @report.edate = sdate + 1.year - 1.day 
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
    @visits, @total, @insured, @uninsured = get_visits( @report )
    @visits = @visits.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page], per_page: 25)
  end

  def show_pdf
   @report = Report.find( params[:id] )
   @public_link = File.join(Rails.root, 'public', "doc_report.pdf")
#   FileUtils.rm @public_link, :force => true
#   FileUtils.cp @report.filespec, @public_link

   if File.exists?(@report.filespec)
     respond_to do |format|
        format.html do   
          send_file @report.filespec,
	     filename: @report.filename,
             type: "application/pdf",
             disposition: :attachment
	end
	format.js {FileUtils.ln_s @report.filespec, @public_link, :force => true}
      end
   else
     flash.now[:danger] = "Error: File #{@report.filename} was not found" 
     redirect_to reports_path
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
    end

    respond_to do |format|
       format.html { @pdf.render_file @report.filespec }
       format.js do									# Due to caching, symlinks don't really work.. Not used
#	 @pdf.render_file File.join(Rails.root, 'public', "doc_report.pdf") 
	 FileUtils.ln_s @report.filespec, File.join(Rails.root, 'public', "doc_report.pdf"), :force => true
       end
    end
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
          Report.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
