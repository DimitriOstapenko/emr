class ChartsController < ApplicationController

   before_action :set_chart, only: [:show, :edit, :update, :download, :destroy]
   helper_method :sort_column, :sort_direction

   before_action :logged_in_user
   before_action :admin_or_staff_user
   before_action :admin_user, only: :destroy

  def index
#!!
    redirect_back(fallback_location: charts_path)
    if current_user.doctor?
      @charts = Chart.where(doctor_id: current_doctor.id)
    else
      @charts = Chart.all
    end
    @charts = @charts.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
  end

  def new
     @chart = Chart.new
  end

  def create
    c = params[:chart][:chart]
    fn = c.original_filename
    patient_id = fn.gsub(/.pdf/,'').to_i rescue nil
    @patient = Patient.find(patient_id) rescue nil

    if @patient.present?
       if @patient.chart_exists?
         @patient.chart.rename rescue nil  # We rename original file to append to it after save
         appended_msg =  'Original file appended'
       end
       @patient.chart.destroy rescue nil
       @patient.chart = Chart.new(chart_params)
#       logger.debug("#################### #{@patient.chart} ")
       if @patient.chart.save
          flash[:success] =  "Chart #{@patient.chart.id} for #{@patient.full_name} uploaded. #{appended_msg}"
          redirect_back(fallback_location: charts_path)
       else
          flash[:danger] = "Error saving chart"
          render json: {error: 'Error saving chart'}, status: 422
       end
    else
         flash[:danger] = "Patient is not found in database. Chart is ignored"
    end
  end

  def show
    if @patient.chart_exists?
      respond_to do |format|
      format.html {
        send_file(@chart.filespec,
             filename: @chart.filename,
             type: "application/pdf",
             disposition: :inline)
             }
      format.js
      end
    else
      redirect_to charts_path, notice: "Chart file #{@chart.filespec} not found"
    end
  end

  def edit
  end

  def update
  end

  def download
    if @patient.chart_exists?
      send_file @chart.filespec,
             filename: @chart.filename, 
             type: "application/pdf",
             disposition: :attachment
    else
      flash.now[:danger] = "File #{@chart.filename} was not found"
      redirect_to charts_path
    end
  end

def destroy
    if @chart.present?
#      File.delete( @chart.filespec ) rescue nil
#      @chart.destroy
#      flash[:success] = "Chart deleted"
      redirect_to charts_url
    end
  end

    def find
      str = params[:findstr].strip
      @charts = myfind(str)
      if @charts.any?
         @charts = @charts.paginate(page: params[:page])
         flash.now[:info] = "Found #{@charts.count} #{'charts'.pluralize(@charts.count)} matching string #{str.inspect}"
      else
         @charts = Chart.paginate(page: params[:page])
         flash.now[:warning] = "Chart for patient  #{str.inspect} was not found"
      end
      render 'index'
  end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_chart
      @chart = Chart.find(params[:id]) rescue nil
      @patient = @chart.patient if @chart
    end

# Find chart my last name, first name or partial/full patient id
    def myfind (str)
        if str.match(/^[[:digit:]]+/)
          Chart.where("patient_id::varchar like ?", "#{str}%" )
        elsif str.match(/^[[:graph:]]+$/)
          Chart.joins(:patient).where("upper(lname) like ?", "%#{str.upcase}%")
        else
          []
        end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chart_params
      params.require(:chart).permit(:patient_id, :doctor_id, :pages, :chart, :filename)
    end

    def sort_column
       Chart.column_names.include?(params[:sort]) ? params[:sort] : "filename"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
