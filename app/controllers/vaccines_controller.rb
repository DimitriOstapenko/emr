class VaccinesController < ApplicationController
	before_action :logged_in_user 
        before_action :admin_user, only: :destroy
	before_action :set_vaccine, only: [:show, :edit, :update, :destroy]

  def index
      @vaccines = Vaccine.paginate(page: params[:page], per_page: $per_page)
  end

  def show
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
    @vaccine.destroy
    flash[:success] = "Vaccine deleted"
    redirect_back(fallback_location: vaccines_path )
  end

  def edit
  end

  def update
    if @vaccine.update_attributes(vaccine_params)
      flash[:success] = "Vaccine updated"
      redirect_to vaccines_url
    else
      render 'edit'
    end
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

private
  def vaccine_params
          params.require(:vaccine).permit(:name, :target, :route, :dose, :din, :notes)
  end

  def set_vaccine
    @vaccine = Vaccine.find(params[:id])
  end


# Find vaccine by last name or health card number, depending on input format  
  def myfind (str)
        if str.match(/^[[:graph:]]+$/)                # name of the vaccine
          Vaccine.where("lower(name) like ?", "%#{str.downcase}%")
        end
  end
  
end
