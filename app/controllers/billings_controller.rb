class BillingsController < ApplicationController
	before_action :logged_in_user #, only: [:index, :edit, :update]
        before_action :admin_user,   only: :destroy
    
    BILLED = VISIT_STATUSES[:Billed]
    READY = VISIT_STATUSES[:'Ready To Bill']
    RMB = BILLING_TYPES[:RMB]

  def index
      date = params[:date] 
      if date.blank? 
         @visits = Visit.where("status=? ", READY)
         flashmsg = "#{@visits.count} ready to bill #{'visit'.pluralize(@visits.count)} found"
      else 
         @visits = Visit.where("date(entry_ts) = ? AND (status=? OR status=?) ", date, BILLED, READY)
         flashmsg = "Billings for #{date} (#{@visits.count})"
      end
      if @visits.any?
         @visits = @visits.paginate(page: params[:page]) #, per_page: $per_page)
	 flash.now[:info] = flashmsg
         render 'index'
      else
         flash.now[:info] = "No billings were found for date #{date}" if date
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

 # CSV export file 
  def export_csv
    targets  = {:mdbilling => 1, :cabmd => 2}
    target = :cabmd

    date = params[:date] 
    if date.blank?
       @visits = Visit.where("status=? ", READY)
       date = Date.today
       flashmsg = "#{date.to_s}.csv export file created. Includes all previously unbilled visits"
    else
       @visits = Visit.where("date(entry_ts) = ? AND (status=? OR status=?) ", date, BILLED, READY)
       flashmsg = "CSV Export file #{date}.csv created. It only includes records for this day" 
    end

    records = 0
   
    begin
      fname = Rails.root.join('export', date.to_s + '.csv')
      file = File.open(fname, 'w')
      @visits.all.each do |v| 
        p = Patient.find(v.patient_id)
	next unless hcp_procedure?(v.proc_code) 

# :mdbilling  group billing not supported, need to bill by provider here
#  str="#{p.lname}	#{p.fname}	#{p.sex}	#{p.dob.strftime("%d/%m/%Y")}	#{p.ohip_num}	#{p.ohip_ver}	"+
#  "#{v.diag_scode}						#{v.hcp_proc_codes}	#{v.entry_ts.strftime("%d/%m/%Y")}	#{v.units} \n"
	
	for i in 1..4
	    str = get_cabmd_str(i,p,v)	
	    next if str.blank?
	    file.write( str ) 
	    records += 1
	end
	v.update_attribute(:status, BILLED) 
      end 
      rescue Errno::ENOENT => e
	flash[:danger] = e.message
      ensure
        file.close unless file.nil?
        flash[:success] = "#{flashmsg} (#{records} alltogether)"
    end
    redirect_back(fallback_location: billings_path )
  end

# EDT format file  
  def export_edt
    ext = Time.now.day.to_s.rjust(3,'0')
    batch = Time.now.day.to_s.rjust(4,'0')
    month_letter = 'ABCDEFGHIJKL'[Time.now.month-1]
    fname = "H#{month_letter}#{GROUP_NO}.#{ext}"
    filespec = Rails.root.join('EDT', fname)
    heh_count = het_count = her_count = 0
    date = params[:date] 
    if date.blank?
       @visits = Visit.where("status=? ", READY)
       date = Date.today
       flashmsg = "#{fname} EDT file created. Includes all previously unbilled visits"
    else
       @visits = Visit.where("date(entry_ts) = ? AND (status=? OR status=?) ", date, BILLED, READY)
       flashmsg = "#{fname} EDT file created for date #{date}. Includes previously billed and ready for billing visits"
       date_str = date.to_date.strftime("%Y%m%d")
    end
   
    begin
      file = File.open(filespec, 'w')
      vfirst = @visits.first
      last_doc_id = vfirst.doc_id
      file.write( heb_record(vfirst, date_str, batch) )
      @visits.all.each do |v| 
        pat = Patient.find(v.patient_id)
        if (v.doc_id != last_doc_id)
          file.write( hee_record(heh_count, her_count, het_count) )
          heh_count = het_count = her_count = 0
	  last_doc_id = v.doc_id
          file.write( heb_record(v, date_str, batch) )
	end
	if hcp_procedure?(v.proc_code) 
          file.write( heh_record(v,pat) )
	  heh_count += 1
	  v.update_attribute(:status, BILLED) 
	  if v.bil_type == RMB  		# only 1 RMB claim supported per visit right now	
	    file.write( her_record(pat) )
	    her_count +=1
	  end
	  file.write( het_record(v, 1, date_str) )
	  het_count += 1
	end
        if !v.proc_code2.blank? && hcp_procedure?(v.proc_code2) 
	  file.write( het_record(v, 2, date_str) )
	  het_count += 1
        end
        if !v.proc_code3.blank? && hcp_procedure?(v.proc_code3) 
	  file.write( het_record(v, 3, date_str) )
	  het_count += 1
        end
        if !v.proc_code4.blank? && hcp_procedure?(v.proc_code4) 
	  file.write( het_record(v, 4, date_str) )
	  het_count += 1
        end
        last_doc_id = v.doctor.id
      end 
      
      file.write( hee_record(heh_count, her_count, het_count) )
      rescue Errno::ENOENT => e
	  flash[:danger] = e.message
	  error = 1
      ensure
       file.close unless file.nil?
    end

    flash[:success] = flashmsg unless error
    redirect_back(fallback_location: billings_path )
  end

private

#  def billing_params
#      params.require(:billing).permit(:pat_id, :doc_code, :visit_id, :visit_date, :proc_code, :proc_units, :fee, :btype, :diag_code, :status,
#				       :amt_paid, :paid_date, :write_off, :submit_file, :remit_file, :remit_year, :moh_ref,
#				       :bill_prov, :submit_user, :submit_ts, :doc_id )
#  end

  def hcp_procedure?(proc_code)
    Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
  end

  def heb_record(v, date, batch)
    "HEBV03G#{date}#{batch}#{' '*6}#{GROUP_NO}#{v.doctor.provider_no}00".ljust(79,' ') + "\n"
  end

  def heh_record(v, pat)
    "HEH#{pat.ohip_num}#{pat.ohip_ver}#{pat.dob.strftime("%Y%m%d")}#{v.id.to_s.rjust(8,'0')}HCPP".ljust(79,' ') +"\n"
  end

  def het_record( v, num, date )
    case num
      when 1
        pcode = v.proc_code; fee = v.fee; units = v.units; dcode = v.diag_code
      when 2 
        pcode = v.proc_code2; fee = v.fee2; units = v.units2; dcode = v.diag_code2
      when 3 
        pcode = v.proc_code3; fee = v.fee3; units = v.units3; dcode = v.diag_code3
      when 4
        pcode = v.proc_code4; fee = v.fee4; units = v.units4; dcode = v.diag_code4
      else 
	return ''
      end
     return "HET#{pcode}  #{(fee*units*100).to_i.to_s.rjust(6,'0')}#{units.to_s.rjust(2,'0')}#{date}#{dcode.to_i.to_s.rjust(3,'0')}".ljust(79,' ') + "\n"
  end
  
  def her_record(pat)
    "HER#{pat.ohip_num.ljust(12,' ')}#{pat.lname[0,9].ljust(9,' ')}#{pat.fname[0,5].ljust(5,' ')}#{DIG_SEXES[pat.sex]}#{pat.hin_prov}".ljust(79,' ') + "\n"
  end
	  
  def hee_record( heh_count, her_count, het_count )
    "HEE#{heh_count.to_s.rjust(4,'0')}#{her_count.to_s.rjust(4,'0')}#{het_count.to_s.rjust(5,'0')}".ljust(79,' ') + "\n"
  end

# CabMD billing import TDV file
# group billing ok, but each service code needs to be on a separate line	  
  def get_cabmd_str(i,p,v)
     case i
     	when 1
	  pcode = v.proc_code; units = v.units
     	when 2
	  return if v.proc_code2.blank?
	  pcode = v.proc_code2; units = v.units2
     	when 3
	  return if v.proc_code3.blank?
	  pcode = v.proc_code3; units = v.units3
     	when 4
	  return if v.proc_code4.blank?
	  pcode = v.proc_code4; units = v.units4
	end
     
     "#{v.doctor.provider_no}	'#{GROUP_NO.rjust(4,'0')}'	#{p.hin_prov}	#{p.ohip_num}	#{p.ohip_ver}	#{p.fname}	#{p.lname}	#{p.dob.strftime("%d/%m/%Y")}	#{p.full_sex}"+
     "		'#{v.diag_scode}'				#{v.entry_ts.strftime("%d/%m/%Y")}	#{pcode}	#{units} 	#{v.id}\n"
  end

end
