class DailyChartsController < ApplicationController
	helper_method :sort_column, :sort_direction

	before_action :logged_in_user 
        before_action :admin_user,   only: :destroy

  def index
      @year =  params[:year] rescue nil
      @month = params[:month] rescue nil
      charts = DailyChart
      @sdate = @edate = nil

      if @year.present?
        @sdate = Date.new(@year.to_i,1) 
        @edate = @sdate + 1.year - 1.day
	charts = charts.where(date: (@sdate..@edate))
        if @month.present?
	  @sdate = Date.parse("#{@month} #{@year.to_i}") 
          @edate = @sdate + 1.month - 1.day
	  charts = charts.where(date: (@sdate..@edate))
	end
      end

      @daily_charts = charts.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) 

  end

  def new
    @chart = DailyChart.find( params[:id] )
  end

  def create
    @chart = DailyChart.find( params[:id] )
  end

  def show
    @chart = DailyChart.find( params[:id] )
    if File.exists?(@chart.filespec)
      respond_to do |format|
      format.html {
        send_file(@chart.filespec,
             filename: "Chart_#{@chart.filename}",
             type: "application/pdf",
             disposition: :inline) 
             }
      format.js
      end
    end
  end

  def download
   @chart = DailyChart.find( params[:id] )

   if File.exists?(@chart.filespec)
          send_file @chart.filespec,
	     filename: @chart.filename,
             type: "application/pdf",
             disposition: :attachment
   else
     flash.now[:danger] = "File #{@chart.filename} was not found" 
     redirect_to charts_path
   end
  end

  def edit
    @chart = DailyChart.find( params[:id] )
  end

  def update
  end

  def destroy
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

private
def patient_params
          params.require(:patient).permit(:filename, :date, :pages, :year, :month )
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
