class DiagnosesController < ApplicationController

	before_action :logged_in_user #, only: [:index, :edit, :update]
	before_action :admin_user, only: :destroy

  def index
    @diagnoses = Diagnosis.paginate(page: params[:page]) #, per_page: 40)
    flash.now[:info] = "Showing All Diagnoses"
  end

  def find
      str = params[:findstr]
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
      redirect_to @diagnosis
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

end

