class BillingsController < ApplicationController

  include My::EDT

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

# EDT claim export (DB,file)  
  def export_edt
    store_location
    month_letter = 'ABCDEFGHIJKL'[Time.now.month-1]
    ttl_claims = docs_processed = 0; errmsg = []

# Which doctors worked on that day?
    docs = Visit.where("status=?", READY).reorder('').group(:doc_id).pluck(:doc_id)
    docs.each do |doc_id|
      doc = Doctor.find(doc_id)
      last_seq_no = 0; last_ttl_amt = 0.0;

# Construct output file name  
      basename = "H#{month_letter}#{doc.provider_no}"
# But first find latest file's seq_no for this doctor 
      last_seq_no = EdtFile.where('filename like ?', "#{basename}.%").order(seq_no: :desc).limit(1).pluck(:seq_no).first || 0
      seq_no = last_seq_no + 1
      ext = seq_no.to_s.rjust(3,'0')
      filename = "#{basename}.#{ext}"
      visits = Visit.where("status=? AND doc_id=?", READY, doc_id)
      next unless visits.any?

# Create empty edt_file object to get the id of a new record
      edt_file = EdtFile.new
      if !edt_file.save(validate: false)
	errmsg[docs_processed] = "could not save edt object for doctor #{doc.lname}"
	next
      end

# Call method from EDT module to genarate claims      
      (body, claims, svcs, ttl_amt) = generate_claim_for_doc(edt_file.id,filename,visits)  # My::EDT
      ttl_claims += claims
      if edt_file.update_attributes(ftype: EDT_CLAIM, filename: filename, upload_date: Time.now, provider_no: doc.provider_no,
               group_no: GROUP_NO, body: body, lines: body.lines.count, claims: claims, services: svcs, total_amount: ttl_amt, seq_no: seq_no )
# Write claim to file
        edt_file.write
        docs_processed += 1
      else
        errmsg[docs_processed] = "Couldn't save "+  edt_file.errors.full_messages.to_sentence
        edt_file.destroy
      end
    end # docs
 
    if errmsg.any?
       flash[:danger] =  "Error: " + flashmsg.join(';')
    else 
       flash[:success] = "#{ttl_claims} claims for #{docs_processed} doctors exported"
    end   
    redirect_back_or( billings_path )
  end

# Send XML file directly to cab.md server
  def export_cabmd
    require 'net/http'
    require 'uri'

    @visits = Visit.where("status=? ", READY)
    
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
