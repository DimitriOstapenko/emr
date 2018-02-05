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
	    Procedure.where("active")
    end    
    
# List of diagnosis, most popular first
    def get_diagnoses
	    Diagnosis.where("active")
    end    

$sexes  = [['Male','M'],['Female','F'],['Unknown','X']] 

$provinces = [['AB', 'AB'], ['BC', 'BC'], ['MB','MB'], ['NB','NB'],
	      ['NL','NL'], ['NS','NS'],['NT','NT'],['NU','NU'],
	      ['ON','ON'],['PE','PE'], ['QC','QC'], ['SK','SK'], ['YT','YT']
	     ]

$billing_statuses = [["3RD CLAIM"],
		     ["DELETED"],
		     ["WCB CLAIM"],
		     ["HCP CLAIM"],
		     ["INVOICED"],
		     ["PAID BY 3RD"],
		     ["PAID BY MOH"],
		     ["WRITTEN OFF"]]    

$billing_types = [["3RD","3RD"],
		  ["RMB","RMB"],
    		  ["WCB","WCB"],
		  ["HCP","HCP"]] 

$statuses = [["Arrived", 1],
	     ["Assessed", 2],
	     ["Cancelled", 3],
	     ["Billed", 4]]

$visit_types = ['WI','PC']

$durations = [[10,10], [20,20], [30,30], [40,40]]

$units = [[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9],[10,10]]
end
