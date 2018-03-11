module ApplicationHelper
       
#	include ActionView::Helpers::NumberHelper 
  
# Guess device type 	
# /mobile|android|iphone|blackberry|iemobile|kindle/
    def device_type
      ua  = request.user_agent.downcase
      if ua.match(/mac os|windows/)
#	 $per_page = 30 
	 return 'desktop'
      else 
  	 $per_page = 15 
	 return 'mobile'
      end
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

# Health card validation
    
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
$sexes  = [['Male','M'],['Female','F'],['Unknown','X']]

$provinces = [['ON','ON'],['AB', 'AB'], ['BC', 'BC'], ['MB','MB'], ['NB','NB'],
              ['NL','NL'], ['NS','NS'],['NT','NT'],['NU','NU'],
              ['PE','PE'], ['QC','QC'], ['SK','SK'], ['YT','YT']
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

$durations = [[10,10], [20,20], [30,30], [40,40]]

$timeframes = [['Day',1],['Month',2],['Year',3]]

$units = [[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9],[10,10]]

$true_false = [['True', 1],['False',0]]

$report_types = {Daily: 1, Monthly: 2, Yearly: 3, 'Date Range': 4, 'All Time': 5}


end
