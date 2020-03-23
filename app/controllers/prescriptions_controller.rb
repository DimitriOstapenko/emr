class PrescriptionsController < ApplicationController

  before_action :set_prescription, only: [:show, :edit, :update, :download, :export, :destroy]
  before_action :admin_or_staff_user
  before_action :logged_in_user

  include My::Forms
  helper_method :sort_column, :sort_direction

  def index
    @patient = Patient.find(params[:patient_id]) rescue nil
    @prescriptions = @patient.prescriptions.paginate(page: params[:page]) if @patient.present?
  end

  def new
    @patient = Patient.find(params[:patient_id]) rescue nil
    @prescription = @patient.prescriptions.new
  end

   def create
    @patient = Patient.find(params[:patient_id])
    @visit = @patient.visits.where('date(entry_ts) = ?', Date.today)[0] rescue nil
    @prescription = @patient.prescriptions.build(prescription_params)
    @prescription.visit_id = @visit.id if @visit.present?
    @prescriptions = @patient.prescriptions.paginate(page: params[:page], per_page: 10)

    if @prescription.save
       @prescription.update_attribute(:filename, "presc_#{@prescription.id}.pdf")
       pdf = build_prescription( @prescription )
       pdf.render_file @prescription.filespec

#       send_file(@prescription.filespec,
#	     filename: "presc_#{@prescription.filename}",
#             type: "application/pdf",
#             disposition: :inline)

       flash[:success] =  "Prescription saved"
       redirect_to @patient
    else
       flash[:danger] =  "Error saving prescription"
       render 'new'
    end
  end

  def show
   respond_to do |format|
      format.html {
        send_file(@prescription.filespec,
             type: "application/pdf",
	     disposition: :inline) rescue nil 
        flash[:warning] = "PDF file is missing"
      }
      format.js
    end
  end

  def edit
  end

  def destroy
    @prescription.destroy
    flash[:success] = "Prescription deleted"
    redirect_to patient_prescriptions_url(@patient)
  end

  def update
    if @prescription.update_attributes(prescription_params)
      pdf = build_prescription( @prescription )
      pdf.render_file @prescription.filespec rescue nil

      flash[:success] = "Prescription updated"
      redirect_to @patient
    else
      flash[:danger] =  "Error saving prescription"
      render 'new'
    end
  end
  
  def download
    if @prescription.pdf_present?
      send_file @prescription.filespec,
             filename: @prescription.filename,
             type: "text/pdf",
             disposition: :attachment
    else
      flash[:danger] = "File #{@prescription.filename} was not found - regenerating"
      redirect_to export_prescription_path(@prescription)
    end
  end

  def export
      pdf = build_prescription( @prescription )
      pdf.render_file @prescription.filespec
      redirect_to patient_prescriptions_url(@patient), alert: "New prescription file generated"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prescription
      @prescription = Prescription.find(params[:id])
      @visit = @prescription.visit
      @patient = @prescription.patient
    end

    def prescription_params
      params.require(:prescription).permit(:visit_id, :doctor_id, :note, repeats:[], duration:[], qty:[], meds:[]) 
    end

end
