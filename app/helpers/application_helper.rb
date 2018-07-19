module ApplicationHelper
       
# Guess device type 	
# /mobile|android|iphone|blackberry|iemobile|kindle/
    def device_type
      ua  = request.user_agent.downcase rescue 'unknown'
      if ua.match(/macintosh|windows/)
#	 WillPaginate.per_page = 34  # doesnt work in multi-thread 
	 return 'desktop'
      else 
#	 WillPaginate.per_page = 20
	 return 'mobile'
      end
    end

# used in diagnosis,daysheet,reports 
    def sortable(column, title = nil)
      title ||= ActiveSupport::Inflector.titleize(column)
#      css_class = column == sort_column ? "current #{sort_direction}" : nil
      direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
      link_to title, { direction: direction, sort: column, date: params[:date]}, {class: "hdr-link"}
    end

# Returns the full title on a per-page basis.
    def full_title(page_title = '')
      base_title = "Walk-In EMR"
      if page_title.empty?
        base_title
      else
        page_title + " | " + base_title
      end
    end

    def project_url 
	'http://walkin.drlena.com'
    end

# Calculate current wait time based on daysheet patient's status    
    def current_wait_time
      (Visit.where("date(entry_ts) = ? AND status = 1", Date.today).count rescue 0) * AVG_MINS_PER_PATIENT
    end	    

# Get list of active doctors in the clinic
    def get_active_doctors
	    Doctor.where("bills = 't'" )
    end

# List of active procedures
    def get_active_procedures
	    Procedure.where("active = 't'")
    end    
    
# List of active diagnoses
    def get_active_diagnoses
	    Diagnosis.where("active = 't'")
    end    

# Health card validation using checksum method
    
    def hcard_valid?( str )
      return unless @number.length == 10
      arr = @number.split('')
      last_digit = arr[-1].to_i

      def sumDigits(num, base = 10)
        num.to_s(base).split(//).inject(0) {|z, x| z + x.to_i(base)}
      end

      sum = 0
      arr[0..arr.length-2].each_with_index do |dig, i|
        sum += i.odd? ? dig.to_i : sumDigits(dig.to_i * 2)
      end

      last_digit == (10 - sum.to_s[-1].to_i)
    end

    def num_to_phone( phone, area_code = true )
      return '' if phone.blank?
      number_to_phone(phone, area_code: :true)
    end

end
