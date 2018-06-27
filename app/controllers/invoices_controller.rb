class InvoicesController < ApplicationController
	include My::Forms

	helper_method :sort_column, :sort_direction

        before_action :logged_in_user 
        before_action :admin_user, only: :destroy

  def index
      @invoices = Invoice.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page], per_page: $per_page)
      flash.now[:info] = "Showing All Invoices (#{@invoices.count})"
  end

  def new
    @invoice = Invoice.new
    @patient = Patient.find(params[:patient_id])
  end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
       @invoice.update_attribute(:filespec, Rails.root.join('invoices',"inv_#{@invoice.id}.pdf")) 
       pdf = build_invoice( @invoice )
       pdf.render_file @invoice.filespec

       send_data pdf.render,
	     filename: File.basename(@invoice.filespec), 
             type: 'application/pdf',
             disposition: 'inline'
    else
       render 'new'
    end
  end

  def show
   @invoice = Invoice.find( params[:id] )

   send_file(@invoice.filespec,
	     type: "application/pdf", 
	     disposition: :inline) rescue 'Invoice file is missing'
  end

  def edit
    @invoice = Invoice.find( params[:id] )
    @patient = Patient.find( @invoice.patient_id ) rescue Patient.new()
  end

  def update
    @invoice = Invoice.find( params[:id] )
    @patient = Patient.find( @invoice.patient_id ) 

    if @invoice.update_attributes(invoice_params)
      pdf = build_invoice( @invoice )
      pdf.render_file @invoice.filespec	    
	    
      flash[:success] = "Invoice updated"
      redirect_to invoices_path
    else
      render 'edit'
    end
  end

  def destroy
    @invoice = Invoice.find( params[:id] )
    if @invoice.present?
      File.delete( @invoice.filespec ) rescue nil
      @invoice.destroy
      flash[:success] = "Invoice deleted"
    end
    redirect_to invoices_url
  end


private
  def invoice_params
          params.require(:invoice).permit(:patient_id, :billto, :visit_id, :amount, :date, :notes, :amount, :paid, :filespec )
  end

  def sort_column
          Invoice.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
