class InvoicesController < ApplicationController
	helper_method :sort_column, :sort_direction

        before_action :logged_in_user 
        before_action :admin_user, only: :destroy

  def index
      @invoices = Invoice.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page], per_page: $per_page)
      flash.now[:info] = "Showing All Invoices (#{@invoices.count})"
  end

  def new
	  @invoice = Invoce.new
  end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
       flash.now[:success] = "Invoice created #{suffix}"
       redirect_to @invoice
    else
       render 'new'
    end
  end

  def show
   @invoice = Invoice.find( params[:id] )

   send_file(Rails.root.join('invoices',"inv_#{@invoice.id}"),
	     filename: "inv_#{@invoice.id}", 
	     type: "application/pdf", 
	     disposition: :inline)
  end

  def edit
	  @invoice = Invoice.find( params[:id] )
  end

  def destroy
    Invoice.find( params[:id] ).destroy
    flash[:success] = "Invoice deleted"
    redirect_to invoices_url
  end


private
  def invoice_params
          params.require(:invoice).permit(:pat_id, :billto, :visit_id, :amount, :date, :notes )
  end

  def sort_column
          Invoice.column_names.include?(params[:sort]) ? params[:sort] : "pat_id"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
