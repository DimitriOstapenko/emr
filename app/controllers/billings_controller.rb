class BillingsController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update]
        before_action :admin_user,   only: :destroy

  def index
      date = params[:date] || Date.today
      @billings = Billing.where("date(visit_date) = ?", date)
      if @billings.any?
               @billings = @billings.paginate(page: params[:page])
               render 'index'
      else
         flash.now[:error] = 'No billings were found for date ' + date.inspect
         render 'shared/empty_page'
      end
  end

  def show
    @patient = Patient.find(params[:patient_id])
    @visit = Visit.find(params[:visit_id])
    @billing = Billing.find(params[:id])
  end

  def new
    @patient = Patient.find(params[:patient_id])
    @visit = Visit.find(params[:visit_id])
    @billing = Billing.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @visit = Visit.find(params[:visit_id])
    @billing = @visit.billings.build(billing_params)
    @billing.doc_code = @visit.doc_code
    @billing.doc_id = @visit.doc_id
    @billing.pat_id = params[:patient_id]
    @billing.visit_date = @visit.entry_ts
    @billing.fee = Procedure.find_by(code: params[:billing][:proc_code]).cost
    if @billing.save
      @billing.submit_user = current_user.name
      @billing.submit_ts = DateTime.now
      flash[:success] = "Billing saved"
    else
	    flash.now[:error] = 'Error saving billing' + @billing.errors.full_messages.to_s
         render 'shared/empty_page'
    end
#    redirect_to patient_visit_path(@patient,@visit)
  end

  def edit
  end

  def update
  end

private

  def billing_params
      params.require(:billing).permit(:pat_id, :doc_code, :visit_id, :visit_date, :proc_code, :proc_units, :fee, :btype, :diag_code, :status,
				       :amt_paid, :paid_date, :write_off, :submit_file, :remit_file, :remit_year, :moh_ref,
				       :bill_prov, :submit_user, :submit_ts, :doc_id )
  end

end
