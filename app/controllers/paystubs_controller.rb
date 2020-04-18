class PaystubsController < ApplicationController
 
	include My::Forms	

        helper_method :sort_column, :sort_direction
        before_action :logged_in_user #, only: [:index, :edit, :update]
        before_action :non_patient_user
        before_action :admin_user, only: :destroy

 def index
    if current_user.doctor?	 
      @paystubs = Paystub.where(doc_id: current_doctor.id).paginate(page: params[:page])
    else 
      @paystubs = Paystub.paginate(page: params[:page])
      (@latest_ra_file,@latest_pay_date) = Claim.order(date_paid: :desc).limit(1).pluck('ra_file,date_paid').first
      current_year_month = Time.now.strftime('%Y%m').to_i
      cur_month = Time.now.strftime("%B") 
      @can_generate_new_paystubs = @latest_pay_date.strftime('%Y%m').to_i == current_year_month rescue false
      suff = @can_generate_new_paystubs ? "Can generate paystubs for #{cur_month}": "Cannot generate #{cur_month} paystubs - file is not available yet" 
      flash.now[:info] = "Latest processed RA file: #{@latest_ra_file}; Latest payment date: #{@latest_pay_date}. " + suff
    end
  end

  def new
    @paystub = Paystub.new
  end
	
  def create
    @paystub = Paystub.new(paystub_params)

    @paystub.year = Time.now.year
    @paystub.month = params[:date][:month].to_i rescue Time.now.month
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
    redirect_to reports_path unless @paystub

    respond_to do |format|
      format.html {
        send_file(@paystub.filespec,
             type: "application/pdf",
             disposition: :inline) rescue 'Paystub file is missing'
      }
      format.js
    end

  end

# Display pdf pay stub if already exported
  def download
   @paystub = Paystub.find( params[:id] )

   if File.exists?(@paystub.filespec)
   send_file @paystub.filespec,
	     filename: @paystub.filename,
             type: "application/pdf",
             disposition: :attachment
   else
     flash.now[:danger] = "File #{@paystub.filename} was not found - regenerating" 
     redirect_to export_paystub_path(@paystub)
   end
  end

# Generate PDF version of the paystub, save in paystubs directory
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
      redirect_to paystubs_path, alert: "New paystub created for Dr. #{@paystub.doctor.lname}"
  end

# Calculate clinic budget for this month: sum of all deductions to the clinic  
  def budget
	  budget = Paystub.where(year: Time.now.year, month: Time.now.month).reorder('').pluck('SUM(clinic_deduction)').first
	  budget ||= 0.0
	  flash.now[:info] = "This month's budget (sum of deductions of all active doctors): #{sprintf("$%.2f",budget)} "
	  render  inline: '', layout: true
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
     params.require(:paystub).permit(:doc_id, :year, :month, :claims, :services, :gross_amt, :clinic_deduction,
				     :net_amt, :ohip_amt, :cash_amt, :ifh_amt, :wcb_amt, :mho_deduction,
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
