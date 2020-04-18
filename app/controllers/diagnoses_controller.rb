class DiagnosesController < ApplicationController

	helper_method :sort_column, :sort_direction
        before_action :logged_in_user, :non_patient_user
	before_action :admin_user, only: :destroy

  def index
    @diagnoses = Diagnosis.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
  end

  def find
      str = params[:findstr].strip
      @diagnoses = myfind(str) 
      if @diagnoses.any?
	 flash.now[:info] = "Found: #{@diagnoses.count} diagnoses"
	 @diagnoses = @diagnoses.paginate(page: params[:page])
         render 'index'
      else
         flash[:danger] = "Diagnosis not found"
	 redirect_to diagnoses_path 
      end
  end

  def show
    @diagnosis = Diagnosis.find(params[:id])
  end

  def new
    @diagnosis = Diagnosis.new
  end

  def create
     @diagnosis = Diagnosis.new(diagnosis_params)
    if @diagnosis.save
#     log_in @user
       flash[:success] = "Diagnosis created"
       redirect_to @diagnosis
    else
       render 'new'
    end	
  end

  def destroy
    Diagnosis.find(params[:id]).destroy
    flash[:success] = "Diagnosis deleted"
    redirect_to diagnoses_url
  end

  def edit
    @diagnosis = Diagnosis.find(params[:id])
  end

  def update
    @diagnosis = Diagnosis.find(params[:id])
    if @diagnosis.update_attributes(diagnosis_params)
      flash[:success] = "Diagnosis updated"
      redirect_to diagnoses_url
    else
      render 'edit'
    end
  end

private
  def diagnosis_params
          params.require(:diagnosis).permit(:code, :descr, :prob_type, :active)
  end

# Find diagnosis by code or description 
  def myfind (str)
        if str.match(/^[[:digit:]]{,3}\.?[[:digit:]]{,3}$/)
          Diagnosis.where("code like ?", "%#{str}%")
        elsif str.match(/^[[:graph:]]+$/)
          Diagnosis.where("lower(descr) like ?", "%#{str}%")
        else
          []
        end
  end

  def sort_column
	  Diagnosis.column_names.include?(params[:sort]) ? params[:sort] : "code"
  end

  def sort_direction
	  %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end

