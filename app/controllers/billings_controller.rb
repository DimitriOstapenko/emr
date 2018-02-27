class BillingsController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update]
        before_action :admin_user,   only: :destroy

  def index
      date = params[:date] || Date.today
      @visits = Visit.where("date(entry_ts) = ? AND status=4", date)
      if @visits.any?
               @visits = @visits.paginate(page: params[:page])
               render 'index'
      else
         flash.now[:warning] = 'No billings were found for date ' + date.inspect
         render 'shared/empty_page'
      end
  end

  def show
    @patient = Patient.find(params[:patient_id])
    @visit = Visit.find(params[:visit_id])
  end

  def new
    @patient = Patient.find(params[:patient_id])
    @visit = Visit.find(params[:visit_id])
  end

  def edit
  end

  def update
  end

  def export
    date = params[:date] || Date.today
    @visits = Visit.where("date(entry_ts) = ? AND status=4", date)
   
    fname = Rails.root.join('export', date.to_s + '.csv')
    begin
      file = File.open(fname, 'w')
      @visits.all.each do |v| 
        p = Patient.find(v.patient_id)
        str="#{v.doctor.provider_no} : #{p.lname} : #{p.fname} : #{p.sex} : #{p.dob.strftime("%d/%m/%Y")} : #{p.ohip_num} : #{p.ohip_ver} : #{v.diag_code} : #{v.proc_codes} : #{v.entry_ts.strftime("%d/%m/%Y")} : #{v.units} \n"
        file.write( str )
      end 
      rescue IOError => e
      ensure
       file.close unless file.nil?
    end
    flash[:info] = "Export file created for date #{date}"
    redirect_to billings_path
  end

private

#  def billing_params
#      params.require(:billing).permit(:pat_id, :doc_code, :visit_id, :visit_date, :proc_code, :proc_units, :fee, :btype, :diag_code, :status,
#				       :amt_paid, :paid_date, :write_off, :submit_file, :remit_file, :remit_year, :moh_ref,
#				       :bill_prov, :submit_user, :submit_ts, :doc_id )
#  end

end
