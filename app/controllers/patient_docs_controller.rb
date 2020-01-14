class PatientDocsController < ApplicationController
  
  before_action :set_patient_doc, only: [:show, :edit, :update, :download, :export, :destroy]
  before_action :logged_in_user

  def index
    @patient = Patient.find(params[:patient_id]) rescue nil
    if @patient.present?
      @patient_docs = @patient.patient_docs
    else
      @patient_docs = PatientDoc.all
    end
    @patient_docs = @patient_docs.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
  end

  def new
    @patient = Patient.find(params[:patient_id])
    @patient_doc = @patient.patient_docs.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
#   logger.debug "*** #{params[:patient_doc][:patient_doc]}"

    @patient_doc = @patient.patient_docs.build(patient_doc_params)
    if @patient_doc.save
       flash[:success] =  "Patient document # #{@patient_doc.id} created"
       redirect_to @patient
    else
      render json: { error: 'Please select all required parameters first' }, status: 422
#      flash[:danger] =  "Error saving patient document"
    end
  end

  def show
    if @patient_doc && @patient_doc.exists?
     respond_to do |format|
        format.html  {send_file(@patient_doc.filespec, type: "application/pdf", disposition: :inline)}
        format.js 
      end
    else 
      flash[:danger] =  "Patient document file #{@patient_doc.patient_doc.url} not found"  
      redirect_to @patient_doc.patient
    end
  end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient_doc
      @patient_doc = PatientDoc.find(params[:id])
    end

    def patient_doc_params
      params.require(:patient_doc).permit(:patient_id, :doctor_id, :date, :doc_type, :patient_doc )
    end

     def sort_column
       Letter.column_names.include?(params[:sort]) ? params[:sort] : "date"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

end
