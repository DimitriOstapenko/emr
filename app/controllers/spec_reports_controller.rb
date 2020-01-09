class SpecReportsController < ApplicationController
  
  before_action :set_spec_report, only: [:show, :edit, :update, :download, :export, :destroy]
  before_action :logged_in_user

  def index
    @patient = Patient.find(params[:patient_id]) rescue nil
    if @patient.present?
      @spec_reports = @patient.spec_reports
    else
      @spec_reports = SpecReport.all
    end
    @spec_reports = @spec_reports.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
  end

  def new
    @patient = Patient.find(params[:patient_id])
    @spec_report = @patient.spec_reports.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
#    flash[:danger] = params.inspect
#    redirect_to @patient

    @spec_report = @patient.spec_reports.build(spec_report_params)
    if @spec_report.save
       flash[:success] =  "Specialist report # #{@spec_report.id} created"
    else
       flash[:danger] =  "Error saving specialist report"
    end
    redirect_to @patient
  end

  def show
    if @spec_report && @spec_report.exists?
     respond_to do |format|
        format.html  {send_file(@spec_report.filespec, type: "application/pdf", disposition: :inline)}
        format.js 
      end
    else 
      flash[:danger] =  "Spec. Report file #{@spec_report.filename.url} not found"  
      redirect_to @spec_report.patient
    end
  end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_spec_report
      @spec_report = SpecReport.find(params[:id])
    end

    def spec_report_params
      params.require(:spec_report).permit(:patient_id, :doctor_id, :date, :app_date, :filename)
    end

     def sort_column
       Letter.column_names.include?(params[:sort]) ? params[:sort] : "date"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

end
