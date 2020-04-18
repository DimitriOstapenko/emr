class ReferralsController < ApplicationController
  before_action :set_referral, only: [:show, :edit, :update, :download, :export, :destroy]
  before_action :logged_in_user, :non_patient_user
# before_action :admin_user, only: :destroy

  include My::Forms
  helper_method :sort_column, :sort_direction

  def index
    @patient = Patient.find(params[:patient_id]) rescue nil
    if current_user.doctor?
      @referrals = Referral.where(doctor_id: current_doctor.id)
    elsif @patient.present?
      @referrals = @patient.referrals
    else
      @referrals = Referral.all
    end
    @referrals = @referrals.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
  end

# We call this always from patient
  def new
    @patient = Patient.find(params[:patient_id])
    @referral = @patient.referrals.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @referral = @patient.referrals.build(referral_params)
    if @referral.save
       @referral.update_attribute(:filename, "ref_#{@referral.id}.pdf")
       pdf = build_referral( @referral )
       pdf.render_file @referral.filespec
       flash[:success] =  "Referral ##{@referral.id} created"
       redirect_to referrals_path
    else
       flash[:danger] =  "Error creating referral"
       render 'new'
    end
  end

  def show
   redirect_to referrals_path unless @referral

   respond_to do |format|
      format.html {
        send_file(@referral.filespec,
             type: "application/pdf",
             disposition: :inline)
      }
      format.js
    end
  end

  def download
      if @referral.present? && File.exists?(@referral.filespec)
      send_file @referral.filespec,
             filename: @referral.filename,
             type: "application/pdf",
             disposition: :attachment
    else
      flash.now[:danger] = "File #{@referral.filename} was not found - regenerating"
      redirect_to export_referral_path(@referral)
    end
  end

# Generate PDF file, save in referrals directory
  def export
    @pdf = build_referral( @referral )
    @pdf.render_file @referral.filespec
    redirect_to referrals_path, alert: "Referral PDF file generated for patient #{@referral.patient.full_name}"
  end
  
  def edit
    @patient = Patient.find( @referral.patient_id )
  end

   def update
    if @referral.update_attributes(referral_params)
      pdf = build_referral( @referral )
      pdf.render_file @referral.filespec

      flash[:success] = "Referral updated"
      redirect_to referrals_path
    else
      render 'edit'
    end
  end

  def destroy
    if @referral.present?
      File.delete( @referral.filespec ) rescue nil
      @referral.destroy
      flash[:success] = "Referral deleted"
    end
    redirect_to referrals_url
  end

# Generate referral form for this visit
#  def referralform
#        @patient = Patient.find(@referral.patient_id)
#	@pdf = build_referral_form( @patient, @visit )
#        
#        respond_to do |format|
#          format.html do
#	    send_data @pdf.render,
#              filename: "referral_#{@patient.full_name}",
#              type: 'application/pdf',
#              disposition: 'inline'
#	  end
#	  format.js { @pdf.render_file File.join(Rails.root, 'public', 'uploads', "referralform.pdf") }
#	end
#  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_referral
      @referral = Referral.find(params[:id])
    end

    def referral_params
      params.require(:referral).permit(:patient_id, :doctor_id, :visit_id, :date, :app_date, :filename, :to_doctor_id, :to_phone, :to_fax, :to_email, :address_to, :reason, :note)
    end

     def sort_column
       Letter.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

end
