class MedicationsController < ApplicationController

  before_action :set_medication, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user

  include My::Forms
  helper_method :sort_column, :sort_direction

  def index
    @patient = Patient.find(params[:patient_id]) rescue nil
    @medications = @patient.medications.paginate(page: params[:page]) if @patient.present?
  end

# New medication is always called from patient profile
  def new
    @patient = Patient.find(params[:patient_id])
    @medication = @patient.medications.new
    @medications = @patient.medications.paginate(page: params[:page], per_page: 10) 
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @medication = @patient.medications.build(medication_params)
    @medications = @patient.medications.paginate(page: params[:page], per_page: 10) 
    id = params[:medication][:name] || params[:medication][:'generic_name']
    if id.present?
      drug = Drug.find(id) 
      @medication.name = drug.name
      if @medication.save
         flash[:success] =  "Medication #{@medication.name} added to the list"
         redirect_back(fallback_location: @patient)
      else
         flash[:danger] =  "Error creating medication"
         render 'new'
      end
    else 
	render 'new' 
    end
  end

  def show
    unless @medication.present?
      flash[:danger] = "Medication does not exist"
      redirect_to @patient
    end
  end
  
  def edit
    @medications = @patient.medications.paginate(page: params[:page], per_page: 10) 
  end

  def update
    if @medication.update_attributes(medication_params)

      flash[:success] = "Medication updated"
      redirect_back(fallback_location: @patient)
    else
      render 'edit'
    end
  end

  def destroy
    if @medication.present?
      @medication.destroy
      flash[:success] = "Medication deleted"
    end
    redirect_back(fallback_location: @patient)
  end
	
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medication
      @patient = Patient.find(params[:patient_id])
      @medication = Medication.find(params[:id])
    end

    def medication_params
      params.require(:medication).permit(:patient_id, :doctor_id, :name, :generic_name, :strength, :dose, :route, :freq, :format, :quantity, :repeats, :date, :active)
    end

     def sort_column
       Letter.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end


end
