class BillingsController < ApplicationController

    helper_method :sort_column, :sort_direction

    before_action :logged_in_user #, only: [:index, :edit, :update]
    before_action :admin_user,   only: :destroy
    

  def index
      @date = Date.parse(params[:date]) rescue nil
      @totalfee = @totalinsured = @totalcash = @total_insured_services = 0
      
        store_location

      if @date.present?
        @visits = Visit.where("date(entry_ts) = ?", @date).where(status: [READY,BILLED,PAID])
      else
        @visits = Visit.where(status: READY )
        @date = Date.today
	flash_add = 'ready to bill'
      end

      @docs_visits = Visit.where("date(entry_ts) = ?",@date).group('doc_id').reorder('').size
      @docs = Doctor.find(@docs_visits.keys) rescue []

      if params[:doc_id]
         @visits = @visits.where(doc_id: params[:doc_id])
         d = Doctor.find(params[:doc_id])
         doctor = "Dr. #{d.lname}" if d.present?
	 flashmsg = "Billings for #{doctor} : #{@visits.count} visits, " 
      else
	 flashmsg = "#{@visits.count} #{flash_add} #{'visit'.pluralize(@visits.count)}," 
      end
      
      @not_ready = Visit.where('date(entry_ts) = ? AND status=?', @date, ARRIVED)

      if @visits.any? && @not_ready.blank?
         @visits.map{|v| @totalfee += v.total_fee}
         @visits.map{|v| @totalcash += v.total_cash}
         @visits.map{|v| @totalinsured += v.total_insured_fees}
         @visits.map{|v| @total_insured_services += v.total_insured_services}

	 @visits = @visits.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
	 flash.now[:info] = "#{flashmsg}  #{@total_insured_services} #{'service'.pluralize(@total_insured_services)}. Total fees: #{sprintf("$%.2f",@totalfee)} Insured: #{sprintf("$%.2f",@totalinsured)} Cash: #{sprintf("$%.2f",@totalcash)}."
	 render 'index'
      elsif @visits.any?    # there are not ready visits
	 flash.now[:info] = "Not ready to submit billing, #{@not_ready.count} #{'visit'.pluralize(@not_ready.count)} in day sheet still require attention"    
	 @visits = @visits.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
	 render 'index'
      else
	 if params[:date].present?
	    flash.now[:info] = "No billed or ready to bill visits found for  #{@date.strftime("%B %d, %Y")}"
	 else 
	    flash.now[:info] = "No ready to bill visits found"
	 end
	 render  inline: '', layout: true
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

  # CSV export file (cab.md - tested)
  def export_csv

    date = params[:date] 
    if date.blank?
       @visits = Visit.where("status=? ", READY).order(:entry_ts)
       date = Date.today.strftime("%Y%m%d")
       sdate = @visits.first.entry_ts.to_date
       edate = @visits.last.entry_ts.to_date
       flashmsg = "#{date}.csv export file created. Includes all previously unbilled visits"
    else
       @visits = Visit.where("date(entry_ts) = ? AND (status=? OR status=?) ", date.to_date, BILLED, READY)
       sdate = edate = date.to_date
       date = date.to_date.strftime("%Y%m%d") 
       flashmsg = "CSV Export file #{date}.csv created. It only includes records for this day" 
    end

    fname = date+'.csv'
    ttl_claims = hcp_claims = rmb_claims = wcb_claims = 0
   
    begin
      filespec = Rails.root.join('export', fname)
      file = File.open(filespec, 'w')
      file.write ("ProviderNumber, GroupNumber, ProvinceCode, HealthNumber, VersionCode, FirstName, LastName, DOB, Gender, ReferringProviderNumber, DiagnosticCode, ServiceLocationType,MasterNumber,AdmissionDate,ServiceDate,ServiceCode,ServiceQty, PatientInstNumber \n")
      @visits.all.each do |v| 
        p = Patient.find(v.patient_id)

	v.services.each do |s|
	    next unless hcp_procedure?(s[:pcode])  # exclude 3-rd party
	    str = get_cabmd_str(p,v,s)	
	    file.write( str ) 
	    ttl_claims += 1
	    hcp_claims += 1 if s[:btype] == 1
	    rmb_claims += 1 if s[:btype] == 2
	    wcb_claims += 1 if s[:btype] == 5
	end
	v.update_attribute(:status, BILLED) 
	v.update_attribute(:export_file, fname) 
      end 
      rescue Errno::ENOENT => e
	flash[:danger] = e.message
      ensure
        file.close unless file.nil?
	expfile = ExportFile.where(name: fname).first_or_create(name: fname, sdate: sdate, edate: edate, ttl_claims: ttl_claims,
							       	hcp_claims: hcp_claims, rmb_claims: rmb_claims, wcb_claims: wcb_claims)
	if expfile.save
           flash[:success] = "#{flashmsg} (#{ttl_claims} services alltogether)"
	else
	   flash[:danger] = "Error saving export file to DB " + expfile.errors.full_messages.join(',')	
	end
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
	    @visits = Visit.where("date(entry_ts) = ? AND (status=? OR status=?) ", date.to_date, BILLED, READY)
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
	  v.update_attribute(:export_file, fname) 
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

# Send XML file directly to cab.md server
  def export_cabmd
    require 'net/http'
    require 'uri'

    date = params[:date] 
#    if date.blank?
       @visits = Visit.where("status=? ", READY)
#       date = Date.today
#    else
#       @visits = Visit.where("date(entry_ts) = ? AND (status=? OR status=?) ", date.to_date, BILLED, READY)
#       flashmsg = "claims out of #{@visits.count} sent to Cab.md for date #{date}."
#    end
    
    claims_sent = 0; errors =[]
    @visits.all.each do |v| 
       @visit = v
# Skip visits without insured services
       next unless v.hcp_services?    
       @patient = Patient.find(v.patient_id)
       @doctor = @visit.doctor
       next unless @patient.ohip_num.present?
       @patient.fname = @patient.full_sex unless @patient.fname.present?
       @xml = render_to_string "/visits/show.xml"

       uri = URI.parse(CABMDURL)
       http= Net::HTTP.new(uri.host,uri.port)
       http.use_ssl = true
       
       req = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/xml'})
       req.body = @xml

       res = http.request(req)
       @xmlhash = JSON.parse(res.body)
       if @xmlhash['success']
	  acc_no = @xmlhash['accounting_number']
          v.update_attribute(:status, BILLED)
          v.update_attribute(:billing_ref, acc_no)
	  claims_sent += 1
       else
	  errors = @xmlhash['errors'] || []
#	  messages = @xmlhash['messages']
	  refid = @xmlhash['reference_id']
#          flash[:danger] = "Error sending claim #{refid} : #{errors.join','}"
          @visit.update_attribute(:status, ERROR)
	  @visit.update_attribute(:billing_ref, errors.join(',')) if errors.present?
       end
    end
 
#    respond_to(:html)
    if errors.any?
      flash[:danger] = "#{errors.count} #{'error'.pluralize(errors.count)} encountered while sending claims"
    else
      flash[:success] = "#{claims_sent} #{'claim'.pluralize(claims_sent)} sent to Cab.md"
    end
    redirect_back(fallback_location: billings_path )
  end

private

#  def billing_params
#      params.require(:billing).permit(:pat_id, :doc_code, :visit_id, :visit_date, :proc_code, :proc_units, :fee, :btype, :diag_code, :status,
#				       :amt_paid, :paid_date, :write_off, :submit_file, :remit_file, :remit_year, :moh_ref,
#				       :bill_prov, :submit_user, :submit_ts, :doc_id )
#  end

# moved to application controller
#  def hcp_procedure?(proc_code)
#    Procedure.find_by(code: proc_code).ptype == PROC_TYPES[:HCP] rescue false
#  end

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

# CabMD billing import CSV file
# group billing ok, but each service code needs to be on a separate line	  
  def get_cabmd_str( p,v,serv )
     "#{v.doctor.provider_no}, #{GROUP_NO.rjust(4,'0')},#{p.hin_prov}, #{p.ohip_num}, #{p.ohip_ver}, #{p.fname}, #{p.lname}, #{p.dob.strftime("%m-%d-%Y")}, #{p.full_sex},"+
	     ",#{v.diag_scode},,,, #{v.entry_ts.strftime("%m-%d-%Y")}, #{serv[:pcode]}, #{serv[:units]}, #{v.id} \n"
  end

  def sort_column
          Visit.column_names.include?(params[:sort]) ? params[:sort] : "entry_ts"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
