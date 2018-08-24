class FormsController < ApplicationController

        helper_method :sort_column, :sort_direction

        before_action :logged_in_user #, only: [:index, :edit, :update]
        before_action :admin_user, only: :destroy

  def index
     if params[:ftype].present?	  
        @forms = Form.where(ftype: params[:ftype])	  
     else
	@forms = Form
     end	
     @forms = @forms.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) 
     flash.now[:info] = "Showing All Forms"
  end

  def find
     str = params[:findstr].strip
     @forms = myfind(str.upcase)
     if @forms.any?
       @forms = @forms.paginate(page: params[:page])
       flash.now[:info] = "Found: #{@forms.count} forms"
       render 'index'
     else
#       flash.now[:warning] = "Form not found #{str.inspect} - #{view_context.link_to('Add New?', new_form_path)} ".html_safe
       flash.now[:warning] = "Form not found #{str.inspect}" 
       render  inline: '', layout: true
      end
  end

  def show
    @form = Form.find(params[:id])
    if File.exists?(@form.filespec)
     send_file @form.filespec,
             filename: @form.filename,
             type: "application/pdf",
             disposition: :attachment
   else
     redirect_to forms_path
   end
  end

  def new
    @form = Form.new
  end

  def create
    @form = Form.new(form_params)
    if @form.save
       flash[:success] = "Form created"
       redirect_to form_path
    else
       render 'new'
    end
  end

  def destroy
    Form.find(params[:id]).destroy
    flash[:success] = "Form deleted"
    redirect_to forms_url
  end

   def edit
    @form = Form.find(params[:id])
  end
 
  def update
    @form = Form.find(params[:id])
    if @form.update_attributes(form_params)
      flash[:success] = "Form updated"
      redirect_to forms_path
    else
      render 'edit'
    end
  end
 

private 
  def form_params
          params.require(:form).permit(:name, :descr, :ftype, :filename, :format, :eff_date, :fillable)
                                            
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