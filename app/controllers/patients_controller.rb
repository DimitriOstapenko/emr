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
       flash[:success] = "Patient created"
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

  def card
    @patient = Patient.find(params[:id])
    @cardstr = params[:cardstr] rescue nil
    if !@cardstr.blank?
       @cardnum = @cardstr[7,10]
       @patient = Patient.find_by(ohip_num: @cardnum)
    end
    if @cardstr 
       flash.now[:success] = "Card info received: #{@cardstr}"
       respond_to do |format|
         format.html { render 'show_card' }
#	 format.js { render js: "alert('format.js: The cardstr: #{@cardstr} : #{@patient.full_name}')" }
	 format.js { render js: "$('#status').html('Found patient: #{@patient.full_name}')" }
       end
    else     
       flash.now[:success] = "Card not received yet  #{params.inspect}"
       @patient = Patient.find(params[:id])
       render 'card'
    end
  end

  def card2 
#	  debugger
    @params = params
    @cardstr = params[:patient][:cardstr] rescue nil
    @cardstr ||= params[:cardstr] rescue nil
#    render js: "alert('The number is: #{params}')"
    if @cardstr 
       flash.now[:success] = "Card info received: #{@cardstr}"
       render 'show_card' 
    else     
       flash.now[:success] = "Card not received yet  #{params.inspect}"
       @patient = Patient.find(params[:id])
       render 'card'
    end
  end

private
  def patient_params
	  params.require(:patient).permit(:lname, :fname, :dob, :sex, :ohip_num, :ohip_ver, 
					  :phone, :mobile, :full_name, :addr, :city, :prov,
					  :postal,:country, :entry_date, :hin_prov, :hin_expiry,
					  :pat_type, :pharmacy, :pharm_phone, :notes, :alt_contact_name,
					  :alt_contact_phone, :email, :family_dr, :lastmod_by, :cardstr
					 )
  end
 
# Find patient by last name or health card number, depending on input format  
  def myfind (str)
	if str.match(/^[[:digit:]]{,10}$/)
      	  Patient.where("ohip_num like ?", "%#{str}%")  
	elsif str.match(/^%B6/)
	  hcnum = str[8,10]
	  Patient.find_by(ohip_num: hcnum)
	elsif str.match(/^[[:graph:]]+$/)
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

end
