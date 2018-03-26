class BillingsController < ApplicationController
	before_action :logged_in_user #, only: [:index, :edit, :update]
        before_action :admin_user,   only: :destroy

  def index
      date = params[:date] || Date.today
      @visits = Visit.where("date(entry_ts) = ? AND (status=3 OR status=4) ", date)
      if @visits.any?
         @visits = @visits.paginate(page: params[:page]) #, per_page: $per_page)
	 flash.now[:info] = "Billings for #{date} (#{@visits.count})"
         render 'index'
      else
         flash.now[:info] = "No billings were found for date #{date.inspect}"
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

  def export_csv
    date = params[:date] || Date.today
    billed = VISIT_STATUSES[:Billed]
    ready = VISIT_STATUSES[:'Ready To Bill']
    @visits = Visit.where("date(entry_ts) = ? AND status=?", date,billed)
    records = 0
   
    fname = Rails.root.join('export', date.to_s + '.csv')
    begin
      file = File.open(fname, 'w')
      @visits.all.each do |v| 
        p = Patient.find(v.patient_id)
#	next unless hcp_procedure?(v.proc_code) 
        str="#{v.doctor.provider_no}	#{p.lname}	#{p.fname}	#{p.sex}	#{p.dob.strftime("%d/%m/%Y")} 	"+
		"#{p.ohip_num}	#{p.ohip_ver}	#{v.diag_code.to_s.rjust(3, "0")}	 #{v.hcp_proc_codes}	 #{v.entry_ts.strftime("%d/%m/%Y")}	#{v.units} \n"
        file.write( str )
	records += 1
	v.update_attribute(:status, billed) 
      end 
      rescue Errno::ENOENT => e
	flash[:danger] = e.message
	error = 1
      ensure
        file.close unless file.nil?
    end
    flash[:success] = "CSV Export file created for date #{date} (#{records} records)" unless error
    redirect_back(fallback_location: billings_path )
  end

  def export_edt
    date = params[:date] || Date.today
    billed = VISIT_STATUSES[:Billed]
    ready = VISIT_STATUSES[:'Ready To Bill']
   
    @visits = Visit.where("date(entry_ts) = ? AND status=?", billed, date)
    ext = Time.now.day.to_s.rjust(4,'0')
    fname = Rails.root.join('EDT', "HL#{GROUP_NO}.#{ext}")
    heh_count = het_count = 0
    date_str = date.to_date.strftime("%Y%m%d")
    begin
      file = File.open(fname, 'w')
      last_doc_id = @visits.first.doc_id
      @visits.all.each do |v| 
        pat = Patient.find(v.patient_id)
        if (v.doc_id != last_doc_id)
	    hee = "HEE#{heh_count.to_s.rjust(4,'0')}#{'0'*4}#{het_count.to_s.rjust(5,'0')}\n"
            file.write( hee )
            heh_count = het_count = 0
	    last_doc_id = v.doc_id
        else	  
	  heb = "HEBV03G#{date_str}#{ext}#{' '*6}#{GROUP_NO}#{v.doctor.provider_no}\n"
          file.write( heb )
	end
	if hcp_procedure?(v.proc_code) 
	  heh = "HEH#{pat.ohip_num}#{pat.ohip_ver}#{pat.dob.strftime("%Y%m%d")}#{v.id.to_s.rjust(8,'0')}HCPP\n"
          file.write( heh )
	  v.update_attribute(:status, billed) 
	  heh_count += 1
	  het = "HET#{v.proc_code}  #{(v.fee*v.units*100).to_i.to_s.rjust(6,'0')}#{v.units.to_s.rjust(2,'0')}#{date_str}#{v.diag_code.to_i.to_s.rjust(3,'0')}".ljust(79,' ') + "\n"
	  file.write( het )
	  het_count += 1
	end
        if !v.proc_code2.blank? && hcp_procedure?(v.proc_code2) 
	  het2 = "HET#{v.proc_code2}  #{(v.fee2*v.units2*100).to_i.to_s.rjust(6,'0')}#{v.units2.to_s.rjust(2,'0')}#{date_str}#{v.diag_code.to_i.to_s.rjust(3,'0')}".ljust(79,' ') + "\n"
	  file.write( het2 )
	  het_count += 1
        end
        if !v.proc_code3.blank? && hcp_procedure?(v.proc_code3) 
	  het3 = "HET#{v.proc_code3}  #{(v.fee3*v.units3*100).to_i.to_s.rjust(6,'0')}#{v.units3.to_s.rjust(2,'0')}#{date_str}#{v.diag_code.to_i.to_s.rjust(3,'0')}".ljust(79,' ') + "\n"
	  file.write( het3 )
	  het_count += 1
        end
        if !v.proc_code4.blank? && hcp_procedure?(v.proc_code4) 
	  het4 = "HET#{v.proc_code4}  #{(v.fee4*v.units4*100).to_i.to_s.rjust(6,'0')}#{v.units4.to_s.rjust(2,'0')}#{date_str}#{v.diag_code.to_i.to_s.rjust(3,'0')}".ljust(79,' ') + "\n"
	  file.write( het4 )
	  het_count += 1
        end
        last_doc_id = v.doctor.id
      end 
      hee = "HEE#{heh_count.to_s.rjust(4,'0')}#{'0'*4}#{het_count.to_s.rjust(5,'0')}\n"
      file.write( hee )
      rescue Errno::ENOENT => e
	  flash[:danger] = e.message
	  error = 1
      ensure
       file.close unless file.nil?
    end

    flash[:success] = "HL#{GROUP_NO}.#{ext} EDT Export file created for date #{date}" unless error
    redirect_back(fallback_location: billings_path )
  end

private

#  def billing_params
#      params.require(:billing).permit(:pat_id, :doc_code, :visit_id, :visit_date, :proc_code, :proc_units, :fee, :btype, :diag_code, :status,
#				       :amt_paid, :paid_date, :write_off, :submit_file, :remit_file, :remit_year, :moh_ref,
#				       :bill_prov, :submit_user, :submit_ts, :doc_id )
#  end

  def hcp_procedure?(proc_code)
    Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue 0
  end

end
