module ApplicationHelper
  
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
	    'http://ruby.drlena.com'
    end


# Get list of active doctors in the clinic
    def get_active_doctors
	    Doctor.where("bills = 't'" )
    end

# List of procedures, most popular first
    def get_procedures
	    Procedure.all
    end    
    
# List of diagnosis, most popular first
    def get_diagnoses
	    Diagnosis.all
    end    
    
end
