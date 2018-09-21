class EdtFilesController < ApplicationController

    helper_method :sort_column, :sort_direction

    before_action :logged_in_user 
    before_action :admin_user, only: [ :edit, :update, :destroy]
    
  def index
	@edt_files = EdtFile.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
	flash[:success] = "Showing All EDT files"
	render 'index'
  end

  def new
  end

  def create
  end

  def show
    @edt_file = EdtFile.find(params[:id]) rescue nil
    redirect_to edt_files_path unless @edt_file

    respond_to do |format|
      format.html {
        send_file(@edt_file.filespec,
             type: "text/plain",
             disposition: :inline) rescue 'File is missing'
      }
      format.js
    end
  end

  def download
    @edt_file = EdtFile.find( params[:id] )

    if File.exists?(@edt_file.filespec)
    send_file @edt_file.filespec,
             filename: @edt_file.filename,
             type: "text/plain",
             disposition: :attachment
    else
      flash.now[:danger] = "File #{@edt_file.filename} was not found - regenerating"
      @edt_file.write
      redirect_to edt_files_path
    end
  end
  
  def destroy
  end

  private 

  def sort_column
          EdtFile.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


end
