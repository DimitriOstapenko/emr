class PaystubsController < ApplicationController
 
	include My::Forms	

 helper_method :sort_column, :sort_direction
 before_action :logged_in_user #, only: [:index, :edit, :update]
 before_action :admin_user, only: :destroy

 def index
    @paystubs = Paystub.paginate(page: params[:page])
    (@latest_ra_file,@latest_pay_date) = Claim.order(date_paid: :desc).limit(1).pluck('ra_file,date_paid').first
    (year,month) = Paystub.order(:year, :month).limit(1).pluck('year,month').first rescue nil
    paystub_date = Date.new(year,month) rescue  Date.today - 1.month
    paystub_year_month = paystub_date.strftime('%Y%m').to_i rescue 0
    @can_generate_new_paystubs = @latest_pay_date.strftime('%Y%m').to_i > paystub_year_month
    suff = @can_generate_new_paystubs ? 'Can generate new paystubs': 'Cannot generate new paystubs - already up to date'

    flash.now[:info] = "Latest processed RA file: #{@latest_ra_file}; Payment issued #{@latest_pay_date} " + suff
  end

  def new
    @paystub = Paystub.new
  end
	
  def create
    @paystub = Paystub.new(paystub_params)

    @paystub.year = Time.now.year
    @paystub.month = Time.now.month
    @sdate = Date.new(@paystub.year, @paystub.month)
    @edate = 1.month.since(@sdate)
    prov_no = @paystub.doctor.provider_no
    
    if Claim.find_by("date_paid > ?", @sdate)
       flash.now[:success] = "Claims were imported for this month. Can create paystub"
#       @paystub.claims = Claim.where(provider_no: prov_no).where(date_paid: (@sdate..@edate)).pluck('count(*)').join
#       @paystub.ohip_amt = Claim.joins(:services).where(provider_no: prov_no).where(date_paid: (@sdate..@edate)).reorder('').pluck("sum(services.amt_paid)/100.0").join
       ((@paystub.claims,@paystub.services,@paystub.ohip_amt,@paystub.ra_file,@paystub.date_paid)) = Claim.joins(:services)
	       .where(provider_no: prov_no)
	       .where(date_paid: (@sdate..@edate))
       	       .reorder('')
               .group(:ra_file,:date_paid)
	       .pluck('count(distinct claims.id), count(*), sum(services.amt_paid)/100.0, claims.ra_file, claims.date_paid')
   
       if @paystub.save
         flash.now[:success] = "Paystub created : #{@paystub.id}"
         redirect_to export_paystub_path(@paystub)
       else
         render 'new'
       end
    else 
       flash[:warning] = "MOH RA file was not processed yet. Can't create paystub"
       redirect_to paystubs_path
    end
 
  end
  
  def show
    @paystub = Paystub.find(params[:id]) rescue nil
    
    if @paystub
       @sdate = Date.new(@paystub.year, @paystub.month)
       @edate = 1.month.since(@sdate)
       @claims = Claim.where(provider_no: @paystub.doctor.provider_no).where(date_paid: (@sdate..@edate))
       @claims = @claims.paginate(page: params[:page], per_page: 25)
#       flash[:success] = "Doctor #{@paystub.doctor.lname} Pay Stub for #{Date::MONTHNAMES[@paystub.month]}  #{@paystub.year}, #{@paystub.claims} claims, #{@paystub.services} services Gross: $#{@paystub.gross_amt} OHIP: $#{@paystub.ohip_amt} Net: $#{@paystub.net_amt}"
    else
      redirect_to paystubs_path 
    end
  end

# Display pdf pay stub if already exported
  def show_pdf
   @paystub = Paystub.find( params[:id] )

   send_file @paystub.filespec,
	     filename: @paystub.filename,
             type: "application/pdf",
             disposition: :attachment
  end

# Generate PDF version of the report, save in reports directory
  def export
      @paystub = Paystub.find(params[:id])
      name = "#{@paystub.doctor.lname}_#{Date::MONTHNAMES[@paystub.month]}_#{@paystub.year}"
      @sdate = Date.new(@paystub.year, @paystub.month)
      @edate = 1.month.since(@sdate)
      svcs = Claim.joins(:services).where(provider_no: @paystub.doctor.provider_no).where(date_paid: (@sdate..@edate)).reorder('').group('services.svc_date,pmt_pgm')
      @claims = svcs.pluck('svc_date, count(distinct claims.id), count(*), pmt_pgm, SUM(amt_subm)/100.0, SUM(amt_paid)/100.0')
      @paystub.update_attribute(:filename, name+'.pdf')

      pdf = build_paystub( @paystub,@claims )

      pdf.render_file @paystub.filespec
      send_data pdf.render,
	  filename: @paystub.filename,
          type: 'application/pdf',
          disposition: :attachment
  end

  def destroy
    @paystub = Paystub.find(params[:id])
    if @paystub.present?
      File.delete( @paystub.filespec ) rescue nil
      @paystub.destroy
      flash[:success] = "Paystub deleted"
    end

    redirect_to paystubs_url, page: params[:page]
  end

  def find
      str = params[:findstr].strip
      @paystubs = myfind(str)
      if @paystubs.any?
         @paystubs = @paystubs.paginate(page: params[:page])
         flash.now[:info] = "Found: #{@paystubs.count} #{'report'.pluralize(@paystubs.count)}"
      else
         @paystubs = Paystub.new
         @paystubs = Paystub.paginate(page: params[:page])
         flash.now[:info] = "Paystub #{str.inspect} was not found"
      end
      render 'index'
  end

private
  def paystub_params
     params.require(:paystub).permit(:doc_id, :year, :month, :claims, :services, :gross_amt, 
				     :net_amt, :ohip_amt, :cash_amt, :ifh_amt, :wcb_amt, 
				     :monthly_premium_amt, :hc_dep_amt, :filename, :ra_file, :date_paid )
  end

  def get_visits( pstub )
          @visits, @total, @insured, @uninsured = []
  end

  def sort_column
          Visit.column_names.include?(params[:sort]) ? params[:sort] : "entry_ts"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


end
