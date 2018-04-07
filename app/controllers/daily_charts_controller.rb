class DailyChartsController < ApplicationController
	helper_method :sort_column, :sort_direction

	before_action :logged_in_user 
        before_action :admin_user,   only: :destroy

  def index
      @daily_charts = DailyChart.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) #, per_page: 40)
      flash.now[:info] = "Showing All day charts (#{@daily_charts.count}) "
  end

  def ind 
      @daily_charts = DailyChart.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) #, per_page: 40)
      flash.now[:info] = "Showing All day charts (#{@daily_charts.count}) "
  end

  def find
      str = params[:findstr].strip
      @daily_charts = myfind(str)
      if @daily_charts.any?
         @daily_charts = @daily_charts.paginate(page: params[:page])
         flash.now[:info] = "Found #{@daily_charts.count} #{'charts'.pluralize(@daily_charts.count)} matching string #{str.inspect}"
         render 'index'
      else
#         @charts = DailyChart.paginate(page: params[:page])
         @daily_charts = DailyChart.new
         flash.now[:warning] = "DailyChart  #{str.inspect} was not found"
         render  inline: '', layout: true
      end
  end

  def new
  end

  def create
  end

  def show
    @chart = DailyChart.find( params[:id] )
    (year,mon,rest) = @chart.filename.split('-') 

    send_file(Rails.root.join(CHARTS_PATH,"Daily/#{year}",@chart.filename),
             filename: "Chart_#{@chart.filename}",
             type: "application/pdf",
             disposition: :inline)

  end

  def index
  end

  def edit
  end

  def update
  end

  def destroy
  end

private
def patient_params
          params.require(:patient).permit(:filename, :date, :pages )
  end

# Find patient by last name or health card number, depending on input format  
  def myfind (str)
        if str.match(/^\d+/)               # ohip_num
          DailyChart.where("filename like ?", "%#{str}%")
	else 
		[]
        end
  end

  def sort_column
          DailyChart.column_names.include?(params[:sort]) ? params[:sort] : "date"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
