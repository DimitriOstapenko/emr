class ClaimsController < ApplicationController

	before_action :logged_in_user 
	before_action :admin_user, only: :destroy
	
	helper_method :sort_column, :sort_direction

  def index
    @doc_id = nil
    @adjusted = params[:adjusted].to_i rescue 0 
    if current_user.doctor?
       prov_no = current_doctor.provider_no
       @doc_id = current_doctor.id
    elsif !params[:filter_doc_id].blank?
       doc = Doctor.find(params[:filter_doc_id])
       prov_no = doc.provider_no
       @doc_id = doc.id
    end
    @claims = Claim
    @claims = @claims.where(provider_no: prov_no) if prov_no.present?
    @claims = @claims.joins(:services).where('amt_subm <> amt_paid').reorder('svc_date desc').group('claims.id,services.svc_date') if @adjusted > 0
    @claims = @claims.paginate(page: params[:page])
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
       @services = @claim.services.paginate(page: params[:page], per_page: 14) 
    else
       redirect_to claims_path
    end
  end
      
private
  def claim_params
          params.require(:claim).permit(:claim_no, :provider_no, :accounting_no, :pat_lname, :pat_fname, 
	      :province, :ohip_num, :ohip_ver, :pmt_pgm, :moh_group_id, :visit_id, :ra_file, :date_paid, :filter_doc_id, :adjusted )
  end

# Find claim by claim_no/ohip_num/accounting_no
  def myfind (str)
        if str.match(/^G[[:digit:]]{,10}$/)
	  Claim.where("claim_no like ?", "#{str.upcase}%")
        elsif str.match(/^[[:digit:]]{,10}$/)
          Claim.where("ohip_num like ?", "%#{str}%")
        elsif str.match(/^[[:graph:]]{,8}$/)
          Claim.where("accounting_no like ?", "%#{str}%" )
        else
          []
        end
  end

  def sort_column
      Claim.column_names.include?(params[:sort]) ? params[:sort] : "claim_no"
  end

  def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
