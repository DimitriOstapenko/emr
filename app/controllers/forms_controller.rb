class FormsController < ApplicationController
        before_action :set_form, only: [:show, :edit, :update, :download, :destroy]
        helper_method :sort_column, :sort_direction

        before_action :logged_in_user
        before_action :admin_user, only: :destroy

  def index
     if params[:ftype].present?	  
        @forms = Form.where(ftype: params[:ftype])	  
     else
	@forms = Form
     end	
     @forms = @forms.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) 
  end

  def show
    respond_to do |format|
      format.html { 
        send_file(@form.filespec,
             filename: @form.filename,
             type: "application/pdf",
             disposition: :inline) 
      }
      format.js 
   end
  end

  def download
    send_file @form.filespec,
      filename: @form.form_identifier,
      type: "application/pdf",
      disposition: :attachment
  end

  def new
    @form = Form.new
    @form.eff_date = Date.today
  end

  def create
    @form = Form.new(form_params)
    if @form.save
       flash[:success] = "Form created"
       redirect_to forms_url 
    else
       render 'new'
    end
  end

  def destroy
    @form.destroy
    flash[:success] = "Form deleted"
    redirect_to forms_url
  end

  def edit
  end
 
  def update
    if @form.update_attributes(form_params)
      flash[:success] = "Form updated"
      redirect_to forms_path
    else
      render 'edit'
    end
  end
 
  def find
     str = params[:findstr].strip
     @forms = myfind(str.upcase)
     if @forms.any?
       @forms = @forms.paginate(page: params[:page])
       flash.now[:info] = "Found: #{@forms.count} forms"
       render 'index'
     else
       flash.now[:warning] = "Form not found #{str.inspect}" 
       render  inline: '', layout: true
      end
  end

private 
  def form_params
      params.require(:form).permit(:name, :descr, :ftype, :filename, :format, :eff_date, :fillable, :form)
  end

  def set_form
    @form = Form.find(params[:id])
    redirect_to forms_path unless @form && @form.filespec 
  end

# Find form by name/description
  def myfind (str)
	  Form.where("upper(name) like ? OR upper(descr) like ?", "%#{str}%", "%#{str}%")
  end

  def sort_column
      Form.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
