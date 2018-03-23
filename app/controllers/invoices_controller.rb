class InvoicesController < ApplicationController

        before_action :logged_in_user 
        before_action :admin_user, only: :destroy

  def index
      @invoices = Invoice.paginate(page: params[:page], per_page: $per_page)
      flash.now[:info] = "Showing All Invoices"
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

   send_file(Rails.root.join('invoices',"invoice_#{@invoice.id}"),
	     filename: "invoice_#{@invoice.id}", 
	     type: "application/pdf", 
	     disposition: :inline)
  end

  def edit
	  @invoice = Invoice.find( params[:id] )
  end

  def destroy
	  @invoice = Invoice.find( params[:id] )
  end


private
  def invoice_params
          params.require(:invoice).permit(:pat_id, :billto, :visit_id, :amount, :date, :notes )
  end

end
