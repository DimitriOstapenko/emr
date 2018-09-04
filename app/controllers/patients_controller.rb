class PatientsController < ApplicationController
	include My::Forms

	before_action :logged_in_user #, only: [:index, :edit, :update]
	before_action :admin_user,   only: :destroy

  def index
      @patients = Patient.paginate(page: params[:page])
      flash.now[:info] = "Showing All Patients (#{@patients.count}) "

  end

  def find
      str = params[:findstr].strip
      @patients = myfind(str) 
      if @patients.any?
         @patients = @patients.paginate(page: params[:page])
	 flash.now[:info] = "Found #{@patients.count} #{'patient'.pluralize(@patients.count)} matching string #{str.inspect}"
         render 'index'
      else
#	 @patients = Patient.paginate(page: params[:page])
	 @patients = Patient.new
	 flash.now[:warning] = "Patient  #{str.inspect} was not found"
	 render  inline: '', layout: true
      end
  end

  def show 
    if Patient.exists?(params[:id]) 
       @patient = Patient.find(params[:id]) 
       if @patient.chart_file.blank?
	  lname_with_underscore = @patient.lname.gsub(' ','_')
	  chart = Dir.glob("#{Rails.root}/charts/#{@patient.lname[0]}/#{lname_with_underscore}\,#{@patient.fname}*\.pdf")
	  @patient.update_attribute(:chart_file, chart[0]) if chart[0]
       end
       @visits = @patient.visits.paginate(page: params[:page], per_page: 14) 
       if !@patient.valid?
	  flash.now[:danger] = @patient.errors.full_messages.to_sentence
       end
    else
       redirect_to patients_path
    end
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)
    @patient.entry_date = DateTime.now
    @patient.lastmod_by = current_user.name
    if @patient.save
       suffix  = ' (Health card is expired)' if (@patient.hin_prov == 'ON' && @patient.pat_type == 'O' &&  @patient.hin_expiry.to_date < Date.today)
       flash[:success] = "Patient created #{suffix}"
       redirect_to @patient
    else
       render 'new'
    end	
  end

  def destroy
    Patient.find(params[:id]).destroy
    flash[:success] = "Patient deleted"
    redirect_back(fallback_location: patients_path )
  end

  def edit
    @patient = Patient.find(params[:id])
  end

  def update
    @patient = Patient.find(params[:id])
    @patient.lastmod_by = current_user.name
    if @patient.update_attributes(patient_params)
      flash[:success] = "Profile updated"
      redirect_to @patient
    else
      render 'edit'
    end
  end

  def label
    @patient = Patient.find(params[:id])
    @pdf  = build_label(@patient)
    respond_to do |format|
	format.html do
          send_data @pdf.render,
	  filename: "label_#{@patient.full_name}",
          type: 'application/pdf',
          disposition: 'inline' 
	end
	format.js { @pdf.render_file File.join(Rails.root, 'public', "label.pdf") }
    end
  end

  def addrlabel
    @patient = Patient.find(params[:id])
    @pdf  = build_address_label(@patient)
    respond_to do |format|
        format.html do
    	  send_data @pdf.render,
	    filename: "addrlabel_#{@patient.full_name}",
            type: 'application/pdf',
            disposition: 'inline' 
	end
	format.js { @pdf.render_file File.join(Rails.root, 'public', "addrlabel.pdf") }
    end
  end

# Get card string from listener, find patient or show form to create one
  def card 
    @cardstr = params[:cardstr] rescue nil
    if @cardstr 
       cardpat = create_patient_from_card ( @cardstr )
       @patient = Patient.find_by(ohip_num: @cardstr[7,10])
       if @patient
	  msg = nil
	  msg = "Last name mismatch: name on the card: '#{cardpat.lname}'" if cardpat.lname.casecmp(@patient.lname) !=0
#	  msg = "First name mismatch: card says '#{cardpat.fname}'" if cardpat.fname.casecmp(@patient.fname) != 0
	  msg = "Gender mismatch: #{cardpat.sex} on the card" if cardpat.sex.casecmp(@patient.sex) != 0

	  if (cardpat.ohip_ver != @patient.ohip_ver) && (cardpat.ohip_ver.length == 2)
	     @patient.update_attribute(:ohip_ver, cardpat.ohip_ver) 
	  end
	  if cardpat.dob != @patient.dob
	     @patient.update_attribute(:dob, cardpat.dob) 
	  end
	  if cardpat.hin_expiry != @patient.hin_expiry
	     @patient.update_attribute(:hin_expiry, cardpat.hin_expiry) 
	  end

	  if msg.present?
	     flash[:danger] = "Card found for #{@patient.lname}, #{@patient.fname} (#{@patient.sex}) #{msg}"
	     redirect_to edit_patient_path(@patient.id)
	  else
	     flash[:info] = "Card found for #{cardpat.lname}, #{cardpat.fname} (#{cardpat.sex})"
             redirect_to @patient
	  end
       else 
	  p = Patient.find_by(lname: cardpat.lname, dob: cardpat.dob)
	  @patient = cardpat 
	  if p.present?
             flash[:danger] = "Patient '#{cardpat.lname}' born #{cardpat.dob} already exists in database with card number #{p.ohip_num}"
	     redirect_to @patient
	  else
	     flash[:info] = 'New Patient'
	     render 'new'
	  end
      #    respond_to do |format|
      #      format.html 
      #	    format.js 
#	  end
       end
    else     
       flash.now[:success] = "Card number not read yet  #{params.inspect}"
       @patient = Patient.find(params[:id])
       redirect_to :back
    end
  end

  def chart
    @patient = Patient.find(params[:id])
    begin
    send_file( @patient.chart_file, type: "application/pdf", disposition: "attachment", filename: "#{@patient.lname}_#{@patient.fname}\.pdf") 
      rescue StandardError => e
	flash[:danger] =  e.message  
        redirect_to @patient 
    end
  end
  def invoices
	  flash[:info] = params
  end

private
  def patient_params
	  params.require(:patient).permit(:lname, :fname, :mname, :dob, :sex, :ohip_num, :ohip_ver, 
					  :phone, :mobile, :full_name, :addr, :city, :prov,
					  :postal,:country, :entry_date, :hin_prov, :hin_expiry,
					  :pat_type, :pharmacy, :pharm_phone, :notes, :alt_contact_name,
					  :alt_contact_phone, :email, :family_dr, :lastmod_by, :cardstr, :visits_count,
				    	  :allergies, :medications, :maid_name, :ifh_number
					 )
  end
 
# Find patient by scanned string /last name[, first name]/ entered health card number/ DOB dd-mm-yyyy or dd-mmm-yyyy or dd/mm/yyyy depending on input format  
  def myfind (str)
	if str.match(/^[[:digit:]]{,12}$/)               # ohip_num
      	  Patient.where("ohip_num like ?", "%#{str}%")  
	elsif str.match(/^%B6/)  			 # scanned card
	  hcnum = str[8,10]
	  Patient.find_by(ohip_num: hcnum)
	elsif str.match('^[[:digit:]]{,2}[/-][[:alpha:]]{3}[/-][[:digit:]]{4}') || # Date Of Birth
	      str.match('^[[:digit:]]{,2}[/-][[:digit:]]{,2}[/-][[:digit:]]{4}')
	  dob = str.to_date rescue '1900-01-01'
	  Patient.where("dob = ?", dob)	
	elsif str.match(/^[[:graph:]]+/)  		 # last name[, fname]
	  lname,fname = str.split(',')
	  if lname.present?
	     lname.strip! 
	     if fname.present?
		fname.strip!
		Patient.where("upper(lname) like ? AND upper(fname) like ?", "%#{lname.upcase}%", "%#{fname.upcase}%") 
	     else
		Patient.where("upper(lname) like ?", "%#{lname.upcase}%") 
	     end
	  end
	else
	  []
	end
  end

# Accept 1st line from health card, return new patient with known data prefilled
  def create_patient_from_card ( str )
    sex = {'1' =>'M', '2'=>'F'}
    pat = Patient.new
    pat.entry_date = DateTime.now
    pat.lastmod_by = current_user.name
    names = str[18,26].split('/')
    pat.ohip_num = str[7,10] rescue ''
    pat.ohip_ver = str[61,2].upcase rescue ''
    pat.lname = names[0].strip rescue ''
    pat.fname = names[1].strip rescue ''
    sdob = str[53,8]
    pat.dob = Date.strptime(sdob, '%Y%m%d')
    exp_dt = str[45,4] + sdob[6,2]
    pat.hin_expiry = Date.strptime(exp_dt,'%y%m%d')
    pat.sex = sex[str[52]]
    return pat
  end

end
