class LettersController < ApplicationController
  before_action :set_letter, only: [:show, :edit, :update, :download, :destroy]
  before_action :logged_in_user 
#  before_action :admin_user, only: :destroy
  
  helper_method :sort_column, :sort_direction

  include My::Forms

  def index
    @patient = Patient.find(params[:patient_id]) rescue nil
    if current_user.doctor?
      @letters = Letter.where(doctor_id: current_doctor.id)
    elsif @patient.present?
	    @letters = @patient.letters
    else
	    @letters = Letter.all
    end
    @letters = @letters.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
  end

# We call this always from patient
  def new
    @patient = Patient.find(params[:patient_id])
    @letter = @patient.letters.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @letter = @patient.letters.build(letter_params)
    if @letter.save
       @letter.update_attribute(:filename, "letter_#{@letter.id}.pdf")
       pdf = build_letter( @letter )
       pdf.render_file @letter.filespec
       redirect_to @letter, notice: 'Letter was successfully created.'
    else
       flash[:danger] =  "Error creating letter"
       render :new
    end
  end

  def show
   redirect_to letters_path unless @letter

   respond_to do |format|
      format.html {
        send_file(@letter.filespec,
             type: "application/pdf",
             disposition: :inline)        
      }
      format.js
    end
  end

  def download
    if File.exists?(@letter.filespec)
      send_file @letter.filespec,
             filename: @letter.filename,
             type: "text/plain",
             disposition: :attachment
    else
      flash.now[:danger] = "File #{@letter.filename} was not found"
      redirect_to letters_path
    end
  end

  def edit
  end

  def update
    if @letter.update(letter_params)
      pdf = build_letter( @letter)
      pdf.render_file @letter.filespec	    
	    
      flash[:success] = "Letter updated"
      redirect_to letters_path
    else
      render 'edit'
    end
  end

  def destroy
    if @letter.present?
      File.delete( @letter.filespec ) rescue nil
      @letter.destroy
      flash[:success] = "Letter deleted"
      redirect_to letters_url
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_letter
      @letter = Letter.find(params[:id])
      @patient = Patient.find( @letter.patient_id )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def letter_params
      params.require(:letter).permit(:title, :patient_id, :visit_id, :doctor_id, :date, :filename, :to, :address_to, :from, :body, :note)
    end

    def sort_column
       Letter.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end


end
