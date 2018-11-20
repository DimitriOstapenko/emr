class ChartsController < ApplicationController

   before_action :set_chart, only: [:show, :edit, :update, :download, :destroy]
   helper_method :sort_column, :sort_direction

   before_action :logged_in_user
   before_action :admin_user, only: :destroy

  def index
    @patient = Patient.find(params[:patient_id]) rescue nil
    if current_user.doctor?
      @charts = Chart.where(doctor_id: current_doctor.id)
    elsif @patient.present?
      @charts = [@patient.chart]
    else
      @charts = Chart.all
    end
    @charts = @charts.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
  end

  def new
    @patient = Patient.find(params[:patient_id])
    @chart = @patient.chart.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @chart = @patient.chart.new
  end

  def show
    redirect_to charts_path unless @chart.present?
    if File.exists?(@chart.filespec)
      respond_to do |format|
      format.html {
        send_file(@chart.filespec,
             type: "application/pdf",
             disposition: :inline)
             }
      format.js
      end
    else
      redirect_to charts_path, notice: "File  not fould"
    end
  end

  def edit
  end

  def update
  end

  def download
     if File.exists?(@chart.filespec)
      send_file @chart.filespec,
             filename: @chart.filename,
             type: "text/plain",
             disposition: :attachment
    else
      flash.now[:danger] = "File #{@chart.filename} was not found"
      redirect_to charts_path
    end
  end

def destroy
    if @chart.present?
#      File.delete( @chart.filespec ) rescue nil
      @chart.destroy
      @patient.update_attribute(:chart_file, nil)
      flash[:success] = "Chart deleted"
      redirect_to charts_url
    end
  end

    def find
      str = params[:findstr].strip
      @charts = myfind(str)
      if @charts.any?
         @charts = @charts.paginate(page: params[:page])
         flash.now[:info] = "Found #{@charts.count} #{'charts'.pluralize(@charts.count)} matching string #{str.inspect}"
         render 'index'
      else
         @charts = DailyChart.new
         flash.now[:warning] = "Chart  #{str.inspect} was not found"
         render  inline: '', layout: true
      end
  end


private
    # Use callbacks to share common setup or constraints between actions.
    def set_chart
      @chart = Chart.find(params[:id])
      @patient = Patient.find( @chart.patient_id )
    end

# Find chart my last name, first name or partial/full patient id
    def myfind (str)
        if str.match(/^[[:digit:]]+/)
          Chart.where("patient_id like ?", "#{str}%" )
        elsif str.match(/^[[:graph:]]+$/)
          Chart.where("filename like ?", "%#{str}%")
        else
          []
        end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chart_params
      params.require(:chart).permit(:patient_id, :doctor_id, :filename, :pages)
    end

    def sort_column
       Chart.column_names.include?(params[:sort]) ? params[:sort] : "filename"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
