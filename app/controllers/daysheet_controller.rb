class DaysheetController < ApplicationController
	
  def index
      fdate = params[:datepicker][:mydate]
      @patients = Patient.cifind_by('date', fdate)
      if @patients.any?
         flash.alert = 'Found: '+ @patients.size.to_s
         if @patients.size == 1
               @patient = @patients.first
               redirect_to @patient
         else
               @patients = @patients.paginate(page: params[:page])
               render 'index'
         end
      else
            flash[:error] = 'Patient ' + last_name.inspect + ' was not found.'
            redirect_to patients_url
      end
  end
end
