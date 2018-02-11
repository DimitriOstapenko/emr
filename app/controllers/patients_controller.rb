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
      else
	  @patients = Patient.paginate(page: params[:page])
	  @not_found = true
	  #  render 'patient_not_found'
      end
     render 'index'
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

private
  def patient_params
	  params.require(:patient).permit(:lname, :fname, :dob, :sex, :ohip_num, :ohip_ver, 
					  :phone, :mobile, :full_name, :addr, :city, :prov,
					  :postal,:country, :entry_date, :hin_prov, :hin_expiry,
					  :pat_type, :pharmacy, :pharm_phone, :notes, :alt_contact_name,
					  :alt_contact_phone, :email, :family_dr, :lastmod_by
					 )
  end
 
# Find patient by last name or health card number, depending on input format  
  def myfind (str)
	if str.match(/^[[:digit:]]{,10}$/)
      	  Patient.where("ohip_num like ?", "%#{str}%") 
	elsif str.match(/^[[:graph:]]+$/)
      	  Patient.where("lower(lname) like ?", "%#{str}%") 
	else
	  []
	end
  end

  def make_label ( pat )
     label = "#{pat.full_name} 
     #{pat.addr} #{pat.city}, #{pat.prov} #{pat.postal} 
     DOB: #{pat.dob.strftime("%d-%b-%Y")} #{pat.age} y.o #{pat.sex} 
     H#: #{pat.ohip_num} V:#{pat.ohip_ver} Exp:#{pat.hin_expiry.strftime("%m/%y")}
     Tel: #{pat.phone} File: #{pat.id}"
  end

end
