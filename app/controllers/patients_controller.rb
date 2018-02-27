class PatientsController < ApplicationController

	before_action :logged_in_user, only: [:index, :edit, :update]
	before_action :admin_user,   only: :destroy


  def index
	  @patients = Patient.paginate(page: params[:page]) #, per_page: 40)
  end

  def find
      str = params[:findstr]
      @patients = myfind(str) 
      if @patients.any?
         @patients = @patients.paginate(page: params[:page])
	 flash.now.alert = 'Found: '+ @patients.size.to_s
         render 'index'
      else
	 @patients = Patient.paginate(page: params[:page])
	 @patients = Patient.new
	 flash.now[:danger] = 'Not found'
	 render 'no_patients_found'
      end
  end

  def show 
    if Patient.exists?(params[:id]) 
       @patient = Patient.find(params[:id]) 
       @visits = @patient.visits.paginate(page: params[:page], per_page: 12) 
       expiry = @patient.hin_expiry.to_date rescue '1900-01-01'.to_date
       if expiry < Date.today
	  flash.now[:danger] = "Health card is expired/no expiry date"
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
       suffix  = ' (Health card is expired)' if @patient.hin_expiry.to_date < Date.today
       flash[:success] = "Patient created" + suffix
       redirect_to @patient
    else
       render 'new'
    end	
  end

  def destroy
    Patient.find(params[:id]).destroy
    flash[:success] = "Patient deleted"
    redirect_to patients_url, page: params[:page]
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
	require 'prawn'
	require "prawn/measurement_extensions"

    @patient = Patient.find(params[:id])
    @label = make_label (@patient)
    pdf = Prawn::Document.new(page_size: [90.mm, 29.mm], page_layout: :portrait, margin: [0.mm,3.mm,1.mm,1.mm])
    pdf.font "Courier", :style => :bold
    pdf.text_box @label, :at => [5.mm,26.mm],
         :width => 82.mm,
         :height => 27.mm,
         :overflow => :shrink_to_fit,
         :min_font_size => 2.mm

    send_data pdf.render,
	  filename: "label_#{@patient.full_name}",
          type: 'application/pdf',
          disposition: 'inline' 
  end

# Get card string from listener, find patient or show form to create one
  def card 
    @cardstr = params[:cardstr] rescue nil
    if @cardstr 
       @patient = Patient.find_by(ohip_num: @cardstr[7,10])
       if @patient
          redirect_to @patient 
       else 
	  @patient = create_patient_from_card ( @cardstr )
          respond_to do |format|
            format.html 
	    format.js 
          end
	  render 'new'
       end
    else     
       flash.now[:success] = "Card not received yet  #{params.inspect}"
       @patient = Patient.find(params[:id])
       redirect_to :back
    end
  end

private
  def patient_params
	  params.require(:patient).permit(:lname, :fname, :dob, :sex, :ohip_num, :ohip_ver, 
					  :phone, :mobile, :full_name, :addr, :city, :prov,
					  :postal,:country, :entry_date, :hin_prov, :hin_expiry,
					  :pat_type, :pharmacy, :pharm_phone, :notes, :alt_contact_name,
					  :alt_contact_phone, :email, :family_dr, :lastmod_by, :cardstr, :visits_count
					 )
  end
 
# Find patient by last name or health card number, depending on input format  
  def myfind (str)
	if str.match(/^[[:digit:]]{,10}$/)               # ohip_num
      	  Patient.where("ohip_num like ?", "%#{str}%")  
	elsif str.match(/^%B6/)  			 # scanned card
	  hcnum = str[8,10]
	  Patient.find_by(ohip_num: hcnum)
	elsif str.match(/^[[:graph:]]+$/)  		 # last name
	  Patient.where("lower(lname) like ?", "%#{str.downcase}%") 
	else
	  []
	end
  end

  def make_label ( pat )
     dob = pat.dob.strftime("%d-%b-%Y") if !pat.dob.blank?
     exp_date = pat.hin_expiry.strftime("%m/%y") if !pat.hin_expiry.blank?	 
     label = "#{pat.full_name} 
     #{pat.addr} #{pat.city}, #{pat.prov} #{pat.postal} 
     DOB: #{dob} #{pat.age} y.o #{pat.sex} 
     H#: #{pat.ohip_num} V:#{pat.ohip_ver} Exp:#{exp_date}
     Tel: #{pat.phone} File: #{pat.id}"
  end

# Accept 1st line from health card, return new patient with known data prefilled
  def create_patient_from_card ( str )
    sex = {'1' =>'M', '2'=>'F'}
    pat = Patient.new
    pat.entry_date = DateTime.now
    pat.lastmod_by = current_user.name
    names = str[18,26].split('/')
    pat.ohip_num = str[7,10] rescue ''
    pat.ohip_ver = str[61,2] rescue ''
    pat.lname = names[0] rescue ''
    pat.fname = names[1] rescue ''
    sdob = str[53,8]
    pat.dob = Date.strptime(sdob, '%Y%m%d')
    exp_dt = str[45,4] + sdob[6,2]
    pat.hin_expiry = Date.strptime(exp_dt,'%y%m%d')
    pat.sex = sex[str[52]]
    return pat
  end

end
