class VaccinesController < ApplicationController
	before_action :logged_in_user #, only: [:index, :edit, :update]
        before_action :admin_user,   only: :destroy

  def index
      @vaccines = Vaccine.paginate(page: params[:page], per_page: $per_page)
      flash.now[:info] = "Showing All Vaccines"
  end

  def find
      str = params[:findstr].strip
      @vaccines = myfind(str)
      if @vaccines.any?
         @vaccines = @vaccines.paginate(page: params[:page])
         flash.now[:info] = "Found #{@vaccines.count} #{'vaccine'.pluralize(@vaccines.count)} matching string #{str.inspect}"
         render 'index'
      else
         @vaccines = Vaccine.paginate(page: params[:page])
         @vaccines = Vaccine.new
         flash.now[:warning] = "Vaccine  #{str.inspect} was not found"
         render  inline: '', layout: true
      end
  end

  def show
    if Vaccine.exists?(params[:id])
       @vaccine = Vaccine.find(params[:id])
    else
       redirect_to vaccines_path
    end
  end

  def new
    @vaccine = Vaccine.new
  end

  def create
    @vaccine = Vaccine.new(vaccine_params)
    if @vaccine.save
       flash[:success] = "Vaccine added "
       redirect_to @vaccine
    else
       render 'new'
    end
  end

  def destroy
    Vaccine.find(params[:id]).destroy
    flash[:success] = "Vaccine deleted"
    redirect_back(fallback_location: vaccines_path )
  end

  def edit
    @vaccine = Vaccine.find(params[:id])
  end

  def update
    @vaccine = Vaccine.find(params[:id])
    if @vaccine.update_attributes(vaccine_params)
      flash[:success] = "Vaccine updated"
      redirect_to @vaccine
    else
      render 'edit'
    end
  end

private
  def vaccine_params
          params.require(:vaccine).permit(:name, :target, :route, :dose, :din, :notes)
  end

# Find vaccine by last name or health card number, depending on input format  
  def myfind (str)
        if str.match(/^[[:graph:]]+$/)                # name of the vaccine
          Vaccine.where("lower(name) like ?", "%#{str.downcase}%")
        end
  end
  
end
