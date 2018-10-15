class ProvidersController < ApplicationController
	before_action :logged_in_user 
        before_action :admin_user, only: :destroy

  def index
     @providers = Provider.paginate(page: params[:page])
  end

  def find
      str = params[:findstr].strip
      @providers = myfind(str)
      if @providers.any?
         @providers = @providers.paginate(page: params[:page])
         flash.now[:info] = "Found: #{@providers.count} insurance providers"
         render 'index'
      else
         flash[:danger] = "Provider not found #{str.inspect}"
#        render  inline: '', layout: true
         redirect_to providers_path
      end
  end

  def new
	  @provider = Provider.new
  end

  def create
    @provider = Provider.new(provider_params)
    if @provider.save
       flash[:success] = "Provider created"
       redirect_to providers_path
    else
       render 'new'
    end

  end

  def show
    @provider = Provider.find(params[:id])
  end

  def destroy
    Provider.find(params[:id]).destroy
    flash[:success] = "Provider deleted"
    redirect_back(fallback_location: providers_path )
  end

  def edit
    @provider = Provider.find(params[:id])
  end

  def update
    @provider = Provider.find(params[:id])
    if @provider.update_attributes(provider_params)
      flash[:success] = "Provider updated"
      redirect_to providers_url
    else
      render 'edit'
    end
  end


private
  def provider_params
          params.require(:provider).permit(:name, :addr1, :addr2, :city, :prov, :postal, :country, :phone1, :phone2, :fax, :email) 
  end

# Find provider by name
  def myfind (str)
        if str.match(/^[[:graph:]]+$/)
          Provider.where("lower(name) like ?", "%#{str}%")
        end
  end


end
