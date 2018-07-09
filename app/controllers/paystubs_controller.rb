class PaystubsController < ApplicationController
 
	include My::Forms	

 helper_method :sort_column, :sort_direction
 before_action :logged_in_user #, only: [:index, :edit, :update]
 before_action :admin_user, only: :destroy

 def index
    @paystubs = Paystub.paginate(page: params[:page])
    flash.now[:info] = "Showing all paystubs (#{@paystubs.count})"
  end

  def find
      str = params[:findstr].strip
      @paystubs = myfind(str)
      if @paystubs.any?
         @paystubs = @paystubs.paginate(page: params[:page])
         flash.now[:info] = "Found: #{@paystubs.count} #{'report'.pluralize(@paystubs.count)}"
      else
         @paystubs = Report.new
         @paystubs = Report.paginate(page: params[:page])
         flash.now[:info] = "Report #{str.inspect} was not found"
      end
      render 'index'
  end

  def new
    @paystub = Paystub.new
  end
	
  def create
    @paystub = Paystub.new(paystub_params)
    @paystub.year = params[:date][:year]
    @paystub.month  = params[:date][:month]
    if @paystub.save
       flash.now[:success] = "Paystub created : #{@paystub.id}"
       redirect_to @paystub
    else
       render 'new'
    end
 
  end
  
  def show
    @paystub = Paystub.find(params[:id])
    redirect_to paystubs_path unless @paystub
    @visits, @total, @insured, @uninsured = get_visits( @paystub )
#    @visits = @visits.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page], per_page: 25)
    @visits = @visits.paginate(page: params[:page], per_page: 25) if @visits
  end

  def update
  end

  def edit
  end

  def destroy
    Paystub.find(params[:id]).destroy
    flash[:success] = "Paystub deleted"
    redirect_to paystubs_url, page: params[:page]
  end

private
  def paystub_params
     params.require(:paystub).permit(:doc_id, :year, :month, :cash_amt, :ifh_amt, :wcb_amt, :monthly_premium_amt, :hc_dep_amt )
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
