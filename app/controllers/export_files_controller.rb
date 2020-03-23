class ExportFilesController < ApplicationController
   before_action :logged_in_user #, only: [:index, :edit, :update]
   before_action :admin_user #,   only: :destroy

  def index
    @export_files = ExportFile.paginate(page: params[:page])
    flash.now[:info] = "Showing All Export files (#{@export_files.count})"
  end

  def show
    @export_file = ExportFile.find(params[:id]) 
    flash.now[:info] = "Export file #{@export_file.name}"
    send_file(Rails.root.join('export',@export_file.name),
	      filename: @export_file.name,
              type: "text/plain",
              disposition: :attachment)
  end

  def destroy
    ExportFile.find(params[:id]).destroy
    flash[:success] = "File deleted"
    redirect_back(fallback_location: export_files_path )
  end


private
  def export_file__params
          params.require(:export_file).permit(:name, :sdate, :edate, :ttl_claims, :hcp_claims, :rmb_claims, :wcb_claims)
  end
  
end
