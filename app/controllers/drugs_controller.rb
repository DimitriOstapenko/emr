class DrugsController < ApplicationController

	before_action :set_drug, only: [:show, :get, :edit, :update, :destroy]
        before_action :logged_in_user 
        before_action :admin_user, only: :destroy

  def index
      @drugs = Drug.paginate(page: params[:page], per_page: $per_page)
  end

  def new
      @drug = Drug.new
  end

  def create
    @drug = Drug.new(drug_params)
    if @drug.save
       flash[:success] = "Medication created"
       redirect_to @drug
    else
       render 'new'
    end

  end

  def show
  end

# need this in /medications/_form
  def get
    respond_to do |format|
      format.json { render json: @drug }  
      format.html
    end
  end

  def edit
  end

  def update
    if @drug.update_attributes(drug_params)
      flash[:success] = "Medication updated"
      redirect_to drugs_url
    else
      render 'edit'
    end
  end

  def destroy
    @drug.destroy
    flash[:success] = "Medication deleted"
    redirect_back(fallback_location: drugs_path )
  end

  def find
      str = params[:findstr].strip
      @drugs = myfind(str)
      if @drugs.any?
         @drugs = @drugs.paginate(page: params[:page])
         flash.now[:info] = "Found #{@drugs.count} #{'medication'.pluralize(@drugs.count)} matching string #{str.inspect}"
         render 'index'
      else
         @drugs = Drug.paginate(page: params[:page])
         @drugs = Drug.new
         flash.now[:warning] = "Medication  #{str.inspect} was not found"
         render  inline: '', layout: true
      end
  end

private
  def set_drug
    @drug = Drug.find(params[:id])
  end

  def drug_params
          params.require(:drug).permit(:name,:dnum, :strength, :dose, :freq, :amount, :status, :generic, :igcodes, 
					   :format, :route, :dur_cnt, :dur_unit, :refills, :cost, :lu_code, :pharmacy,
					   :aliases, :dtype, :odb, :filename, :notes, :instructions)
  end

# Find by name
  def myfind (str)
        if str.match(/^[[:graph:]]+$/)
          Drug.where("lower(name) like ?", "%#{str}%")
        end
  end


end
