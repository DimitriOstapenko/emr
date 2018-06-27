class ProceduresController < ApplicationController
	helper_method :sort_column, :sort_direction

        before_action :logged_in_user #, only: [:index, :edit, :update]
        before_action :admin_user, only: :destroy

  def index
     @procedures = Procedure.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) #, per_page: 40)
     flash.now[:info] = "Showing All Procedures"
  end

  def find
      str = params[:findstr].strip
      @procedures = myfind(str.upcase)
      if @procedures.any?
         @procedures = @procedures.paginate(page: params[:page])
         flash.now[:info] = "Found: #{@procedures.count} procedures"
         render 'index'
      else
	 flash.now[:warning] = "Procedure not found #{str.inspect} - #{view_context.link_to('Add New?', new_procedure_path)} ".html_safe
	 render  inline: '', layout: true
#	 redirect_to procedures_path 
      end
  end

# Called by JS in visit _form  
  def get_by_code
    code = params[:code]
    proc = Procedure.find_by(code: code).as_json
    respond_to do |format|
        format.json {
            render json: proc
        }
    end
  end

  def show
    @procedure = Procedure.find(params[:id])
  end

  def new
    @procedure = Procedure.new
  end

  def create
    @procedure = Procedure.new(procedure_params)
    if @procedure.save
       flash[:success] = "Procedure created"
       redirect_to procedures_path
    else
       render 'new'
    end
  end

  def destroy
    Procedure.find(params[:id]).destroy
    flash[:success] = "Procedure deleted"
    redirect_to procedures_url
  end

   def edit
    @procedure = Procedure.find(params[:id])
  end

  def update
    @procedure = Procedure.find(params[:id])
    if @procedure.update_attributes(procedure_params)
      flash[:success] = "Procedure updated"
      redirect_to procedures_url 
    else
      render 'edit'
    end
  end

private
  def procedure_params
          params.require(:procedure).permit(:code, :qcode, :ptype, :descr, :cost, :prov_fee, :ass_fee, :spec_fee, :ana_fee, :non_ana_fee,
					    :unit, :fac_req, :adm_req, :diag_req, :ref_req, :percent, :eff_date, :term_date, :active)
  end

# Find procedure by code/description
  def myfind (str)
	if str.match(/^\S?[[:digit:]]{,3}\S?$/)
          Procedure.where("code like ?", "%#{str}%")  
        elsif str.match(/^[[:graph:]]+$/)
          Procedure.where("upper(descr) like ?", "%#{str}%")
        else
          []
        end
  end

  def sort_column
      Procedure.column_names.include?(params[:sort]) ? params[:sort] : "code"
  end

  def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
