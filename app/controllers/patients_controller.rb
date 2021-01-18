class PatientsController < ApplicationController
	include My::Forms
        include PatientsHelper

	before_action :logged_in_user, except: [:get, :lookup, :lookup4 ]
	before_action :non_patient_user, except: [:show, :edit, :update, :label, :visit_history, :chart ]
	before_action :admin_user, only: :destroy
        before_action :verify_patient  # is patient set and is rigtht patient?

        helper_method :sort_column, :sort_direction
        rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found

  def index
      @sort = sort_column
      @direction = sort_direction
      keyword = params[:findstr]
      if keyword
         @patients = Patient.search(keyword)
      else
         @patients = Patient.all
      end
#      @patients = @patients.where(family_dr: current_doctor.lname) if current_user.doctor?
      @patients = @patients.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page]) 
      flash[:info] = "#{@patients.count} patients found" if keyword
  end

# try and get 1 patient by full ohip_num 
  def get 
    fullnum = params[:findstr].strip.upcase
    str = fullnum.gsub(/\D/,'') if fullnum
    return if str.blank?
    @patient = Patient.find_by(ohip_num: str) || Patient.hcv_lookup(fullnum)
    if @patient.present?
      set_pat_session(@patient.id)
      response = { patient: @patient, user: @patient.user }
      respond_to do |format|
        format.json { render json: response.to_json }
        format.html
      end
    else
        flash.now[:warning] = "Patient not found #{str.inspect} "
        render  inline: '', layout: true
    end
  end

  def show 
    redirect_to patients_path(findstr: params[:findstr]) if params[:findstr]
    @patient = Patient.find(params[:id]) 
    if @patient.lname.present? && @patient.mobile_or_home_phone.present? 
      @visits = @patient.visits.paginate(page: params[:page], per_page: 14) 
      flash.now[:danger] = @patient.errors.full_messages.to_sentence unless @patient.valid?
    else
      redirect_to edit_patient_path(@patient), warning: "Please provide your phone number " 
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
       expiry = @patient.hin_expiry rescue '1900-01-01'.to_date
       suffix  = ' (Health card is expired)' if (@patient.hin_prov == 'ON' && @patient.pat_type == 'O' &&  expiry < Date.today)
       flash[:info] = "Patient created #{suffix}"
       redirect_to @patient
    else
       render 'new'
    end	
  end

  def destroy
    Patient.find(params[:id]).destroy
    flash[:info] = "Patient deleted"
    redirect_back(fallback_location: patients_path )
  end

  def edit
    @patient = Patient.find(params[:id])
  end

  def update
    @patient = Patient.find(params[:id])
    @patient.lastmod_by = current_user.name
    if @patient.update_attributes(patient_params)
      flash[:info] = "Patient profile updated"
      redirect_to patient_path(@patient)
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
	format.js { @pdf.render_file File.join(Rails.root, 'public', 'uploads', "label.pdf") }
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
	format.js { @pdf.render_file File.join(Rails.root, 'public', 'uploads', "addrlabel.pdf") }
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
	     flash[:danger] = "Patient found: #{@patient.lname}, #{@patient.fname} (#{@patient.sex}) #{msg}"
	     redirect_to edit_patient_path(@patient.id)
	  else
	     flash[:info] = "Patient found: #{cardpat.lname}, #{cardpat.fname} (#{cardpat.sex})"
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
       end
    else     
       flash.now[:info] = "Card number not read yet  #{params.inspect}"
       @patient = Patient.find(params[:id])
       redirect_to :back
    end
  end

  def chart
    @patient = Patient.find(params[:id])
    begin
      send_file @patient.chart.filespec,
        filename: @patient.chart.filename,
        type: "application/pdf",
        disposition: :attachment

      rescue StandardError => e
	flash[:danger] =  e.message  
        redirect_to @patient 
    end
  end

  def invoices
    flash[:info] = params
  end

  def visit_history
    @patient = Patient.find(params[:id])
    @pdf  = build_visit_history(@patient)
    respond_to do |format|
        format.html do
          send_data @pdf.render,
	    filename: "#{@patient.full_name}_visits.pdf",
            type: 'application/pdf',
            disposition: 'inline'
        end
	format.js { @pdf.render_file  @patient.visit_history_file }
    end
  end

  # Preliminary lookup by DOB and last 4 digits of HC
  def lookup4
    ohip4 = params[:user][:ohip4].strip rescue nil
    dob = params[:user][:dob].to_date rescue nil
    if ohip4.present? && dob.present?
      patients = Patient.search(ohip4)
      patient = patients.where(dob: dob).first if patients
      if patient.present? && patient.user.present?
        flash[:danger] = "Patient with this health card number is already registered. Please try logging in"
        redirect_to root_path
      else
        ohip_num =  patient.ohip_num_full rescue nil
        @resource = User.new(ohip_num: ohip_num, dob: dob)
        render "devise/registrations/new"
      end
    else
      redirect_to root_path
    end
  end

# Patient lookup by full ohip number  
  def lookup
    fullnum = params[:patient][:ohip_num].strip.upcase rescue nil
    ohip_num,ohip_ver = fullnum.match(/([[:digit:]]{10})\s*([[:alpha:]]{2}?)/).captures rescue nil

    @patient = Patient.find_by(ohip_num: ohip_num) 
    if @patient.present?
      set_pat_session(@patient.id)
      @patient.update_attribute(:ohip_ver, ohip_ver) if @patient.card_valid?  # Override version just in case
      if User.exists?(ohip_num: ohip_num)
        flash[:info] = "You are already registered - please log in, #{@patient.fname.capitalize}"
        redirect_to new_user_session_path
      else
 #       flash[:info] = "Patient record found, but user is not registered yet"
        redirect_to new_user_registration_path
      end
    else
      @patient = Patient.hcv_lookup(fullnum)
      if @patient.id
        set_pat_session(@patient.id)
        flash[:info] = "New Patient with valid card"
        redirect_to new_user_registration_path
      else
        flash[:warning] = "Bad card number: #{@patient.notes}"
        redirect_to root_path
      end
    end
    
  end

private
  def patient_params
	  params.require(:patient).permit(:lname, :fname, :mname, :dob, :sex, :ohip_num, :ohip_ver, 
					  :phone, :mobile, :full_name, :addr, :city, :prov, :country,
					  :postal,:country, :entry_date, :hin_prov, :hin_expiry,
					  :pat_type, :pharmacy, :pharm_phone, :pharm_fax, :notes, :alt_contact_name,
					  :alt_contact_phone, :email, :family_dr, :lastmod_by, :cardstr, :visits_count,
				    	  :allergies, :meds, :maid_name, :ifh_number, :clinic_pat, :validated_at, :latest_medication_renewal
					 )
  end
 
# Accept 1st line from health card, return new patient with known data prefilled
  def create_patient_from_card ( str )
    sex = {'1' =>'M', '2'=>'F'}
    pat = Patient.new
    pat.entry_date = DateTime.now
    pat.lastmod_by = current_user.name
    names = str[18,26].split('/') rescue ''
    pat.ohip_num = str[7,10] rescue ''
    pat.ohip_ver = str[61,2].upcase rescue ''
    pat.lname = names[0].strip rescue ''
    pat.fname = names[1].strip rescue ''
    sdob = str[53,8]
    pat.dob = Date.strptime(sdob, '%Y%m%d')
    exp_dt = str[45,4] + sdob[6,2]
    pat.hin_expiry = Date.strptime(exp_dt,'%y%m%d') rescue '1900-01-01'.to_date
    pat.sex = sex[str[52]]
    return pat
  end

  def sort_column
      Patient.column_names.include?(params[:sort]) ? params[:sort] : "lname,fname"
  end

  def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def record_not_found(exception)
      flash[:warning] = exception.message
      redirect_back fallback_location: patients_path
  end

end
