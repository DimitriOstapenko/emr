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
    
end
