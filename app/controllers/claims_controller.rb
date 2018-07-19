class ClaimsController < ApplicationController

	before_action :logged_in_user #, only: [:index, :edit, :update]
	before_action :admin_user,   only: :destroy

  def index
      @claims = Claim.paginate(page: params[:page])
      flash.now[:info] = "Showing All Claims (#{@claims.count}) "
  end

  def find
      str = params[:findstr].strip
      @claims = myfind(str) 
      if @claims.any?
         @claims = @claims.paginate(page: params[:page])
	 flash.now[:info] = "Found #{@claims.count} #{'claim'.pluralize(@claims.count)} matching string #{str.inspect}"
         render 'index'
      else
	 @claims = Claim.new
	 flash.now[:warning] = "Claim  #{str.inspect} was not found"
	 render  inline: '', layout: true
      end
  end

  def show 
    if Claim.exists?(params[:id]) 
       @claim = Claim.find(params[:id]) 
       if @claim.chart_file.blank?
	  lname_with_underscore = @claim.lname.gsub(' ','_')
	  chart = Dir.glob("#{Rails.root}/charts/#{@claim.lname[0]}/#{lname_with_underscore}\,#{@claim.fname}*\.pdf")
	  @claim.update_attribute(:chart_file, chart[0]) if chart[0]
       end
       @visits = @claim.visits.paginate(page: params[:page], per_page: 14) 
       if !@claim.valid?
	  flash.now[:danger] = @claim.errors.full_messages.to_sentence
       end
    else
       redirect_to claims_path
    end
  end
      

end
