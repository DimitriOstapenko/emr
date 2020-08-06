class Patient < ApplicationRecord
        has_many :visits, dependent: :destroy #, inverse_of: :patient
	has_many :doctors, through: :visits 

        has_many :invoices, dependent: :destroy, inverse_of: :patient
        has_many :letters, dependent: :destroy, inverse_of: :patient
        has_many :referrals, dependent: :destroy, inverse_of: :patient
        has_many :medications, dependent: :destroy, inverse_of: :patient
        has_many :prescriptions, dependent: :destroy, inverse_of: :patient
        has_many :patient_docs, dependent: :destroy, inverse_of: :patient
        has_one :chart, inverse_of: :patient

        has_one :user, dependent: :destroy

  	accepts_nested_attributes_for :invoices, :allow_destroy => false, reject_if: proc { |attributes| attributes['filespec'].blank? }
  	accepts_nested_attributes_for :letters, :allow_destroy => false, reject_if: proc { |attributes| attributes['filespec'].blank? }
  	accepts_nested_attributes_for :referrals, :allow_destroy => false, reject_if: proc { |attributes| attributes['filespec'].blank? }
#	accepts_nested_attributes_for :visits,  :reject_if => :all_blank, :allow_destroy => true
	attr_accessor :full_name, :age, :cardstr, :phonestr
        default_scope -> { includes(:chart).order(lname: :asc, fname: :asc) }

	before_validation :cleanup_some_fields 

	# Force Patient to RMB if province is not ON, to HCP if province is ON when HC number present	
	before_save { self.pat_type = 'O' if self.ohip_num.present? && self.hin_prov == 'ON' && self.pat_type == 'R';
		      self.pat_type = 'R' if self.ohip_num.present? && self.hin_prov != 'ON' && self.pat_type == 'O'; }
        after_save :unmark_as_new

#	validates :pat_type, presence: true, length: { is: 1 }
	validates :lname, presence: true, length: { maximum: 50 }
	validates :ohip_num,  presence:true, length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true,
		  if: Proc.new { |a| (a.hin_prov == 'ON' &&  a.pat_type == 'O') || a.pat_type == 'R' }
	validates :ifh_number,  presence:true, length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true,
		  if: Proc.new { |a| (a.pat_type == 'I')}
#	validates :ohip_ver, length: { is: 2 }, if: Proc.new { |a| a.hin_prov == 'ON' &&  a.pat_type == 'O'}
	validates :dob, presence: true
	validates :sex, presence: true, length: { is: 1 },  inclusion: %w(M F X) 
	validates :postal, length: { maximum: 6 }, allow_blank: true
        validates :phone, presence: true, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
        validates :mobile, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
        validates :pharm_phone, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
	
	validate :validate_card
	validate :validate_age

  def full_name
    fn = self.lname 
    fn = "#{fn}, #{self.fname}" if self.fname.present?
    fn = "#{fn} #{self.mname}" if self.mname.present?
    return fn
  end
 
# Construct Chart filename to be used for downloads
  def chart_filename
    fn = self.lname
    fn = "#{fn},#{self.fname}" if self.fname.present?
    fn = "#{fn}_#{self.mname}" if self.mname.present?
    fn = fn.strip.gsub(/\s+/,'_')
    return fn.concat('.pdf')
  end  
  
  def chart_exists?
    self.chart.present? && self.chart.exists?
  end

# mm/yy
  def hin_expiry_short
      hin_expiry.strftime("%m/%y") rescue '01/00'
  end

  def ohip_num_full
    return ohip_ver.blank? ? ohip_num : [ohip_num, ohip_ver].join(' ')
  end
  
  def ohip_or_ifh_num_full
    if pat_type == IFH_PATIENT	  
      ifh_number	    
    else	    
      ohip_ver.blank? ? ohip_num : [ohip_num, ohip_ver].join(' ')
    end
  end

  def pat_type_str 
    return self.pat_type == CASH_PATIENT ? 'CASH PATIENT' : 'INSURED PATIENT'  
  end

# Formatted home phone number
  def phonestr
    ActiveSupport::NumberHelper.number_to_phone(phone, area_code: :true)
  end

# Formatted home phone number
  def mobilestr
    ActiveSupport::NumberHelper.number_to_phone(mobile, area_code: :true)
  end

  def mobile_or_home_phone
    mobilestr.present? ?  mobilestr : phonestr
  end 

  def addr_full
    "#{addr} #{city}, #{prov} #{postal}"
  end

# Sex: Male, Female, Unknown
  def full_sex
    SEXES.invert[sex].to_s rescue 'Unknown'
  end

# Calculate age in (years,months) and days  
  def age
    return unless dob
    days = (Date.today - dob).to_i
    years = (days / 365).to_i
    months = ((days % 365) / 30).to_i
    return [years, months, days]
  end

  def age_str
    return '' unless (self.age.present? && self.age.any? && self.age.size == 3)
    case 
    when age[0] > 2		       
	    return "#{age[0]}y"
    when (age[2] > 60 && age[0] <= 2)   # 2 mo to 2 yrs old
	    return "#{age[0]*12 + age[1]}m"  
    when (age[0] < 1 && age[1] <= 2)  # up to 2 mo old
            return "#{age[2]}d" 
    end
  end

  def invoices
	  Invoice.where(patient_id: self.id)
  end

  def validate_card
   return unless self.ohip_num.present? && self.ohip_ver.present?
# Don't validate out of province or non-ohip numbers   
    if (hin_prov == 'ON' &&  pat_type == 'O')
      (errors.add(:ohip_num, "Card number for ON must be 10 digits long "); return) if ohip_num.length != 10
      expiry = hin_expiry.to_date rescue '2030-01-01'.to_date
      (errors.add(:hin_expiry, "Card is expired"); return) if expiry < Date.today
    end 

# Check sum test is disabled for now    
    return
    arr = ohip_num.split('')
    last_digit = arr[-1].to_i

    def sumDigits(num, base = 10)
       num.to_s(base).split(//).inject(0) {|z, x| z + x.to_i(base)}
    end

    sum = 0
    arr[0..arr.length-2].each_with_index do |dig, i|
        sum += i.odd? ? dig.to_i : sumDigits(dig.to_i * 2)
    end

    return if (last_digit == (10 - sum.to_s[-1].to_i))
    errors.add(:ohip_num, "Number is invalid") 
  end

  # List of active medications (Array)
  def med_list
      list = self.medications.where(active: true)
      list.map{|med| "#{med.name} #{med.strength} #{med.freq}"} if list.any?
  end
  
  # Hash of active medications 
  def med_hash
      list = self.medications.where(active: true)
      list.map{|med| ["#{med.name} #{med.strength} #{med.route} (#{med.dose} #{med.format}) #{med.freq}",med.id]}.to_h if list.any?
  end

# Count of active medications
  def med_count
      self.med_list.count rescue 0
  end

  def prescription_count
      self.prescriptions.count rescue 0
  end

  def visit_history_file
     File.join(Rails.root, 'public', 'uploads', "visit_history.pdf") 
  end

# Global search method
  def self.search(keyword = '')
    case keyword
     when /^[[:digit:]]{4}$/       # Last 4 digits of HC number
       patients = Patient.where("ohip_num ~ ?", "#{keyword}$")
     when /^[[:digit:]]{,12}$/    # Up to 12 Digits - HC number
       patients = Patient.where("ohip_num like ?", "%#{keyword}%")
     when /^%B6/                  # Scanned card
       hcnum = keyword[8,10]
       patients = Patient.find_by(ohip_num: hcnum)
     when /^[[:digit:]]{,2}[\/-][[:alpha:]]{3}[\/-][[:digit:]]{4}/ ,   # Date like 10-Jun-1962
          /^[[:digit:]]{,2}[\/-][[:digit:]]{,2}[\/-][[:digit:]]{4}/       # or like   30/12/1962
       dob = keyword.to_date rescue '1900-01-01'
       patients = Patient.where("dob = ?", dob)
     when /^[[:graph:]]+/                                             # last name[, fname] 
       lname,fname = keyword.tr(' ','').split(',')
       if fname.blank?        # Search by last name or maiden name if no first name given          
         patients = Patient.where("upper(lname) like ? OR upper(maid_name) like ?", "#{lname.upcase}%", "%#{lname.upcase}")
       else
         patients = Patient.where("upper(lname) like ? AND upper(fname) like ?", "#{lname.upcase}%", "%#{fname.upcase}%")
       end
     else
       patients = []
     end

    return patients.order(:fname) rescue nil
  end

  def has_visit_today?
    self.visits.order(entry_ts: :desc).first.entry_ts.today? rescue false
  end

protected

  def cleanup_some_fields
    self.email.downcase! rescue '' 
    self.ohip_num = ohip_num.gsub(/\D/,'') rescue nil 
    self.phone.gsub!(/\D/,'') rescue '' 
    self.mobile.gsub!(/\D/,'') rescue ''
    self.pharm_phone.gsub!(/\D/,'')  rescue '' 
    self.postal.tr!(' -','') rescue '' 
    self.ohip_ver.strip! rescue ''
    self.fname.strip!.gsub!(/\s+/,' ') rescue '' 
    self.lname.strip!.gsub!(/\s+/,' ') rescue '' 
    self.ohip_ver.upcase! if ohip_ver.present?
    self.postal.upcase! if postal.present?
    self.lname.upcase! if lname.present?
    self.fname.upcase! if fname.present?
    self.mname.upcase! if mname.present?
    self.maid_name.upcase! if maid_name.present?
    self.hin_expiry ||= '2030-01-01'.to_date
    pat_type ||= 'O'
  end

  def validate_age
      return unless dob.present?
#      if dob < 110.years.ago || dob > Date.yesterday
      if !dob.between?(110.years.ago, Date.today)
          errors.add(:dob, 'Date of birth is out of range')
      end
  end

# User is redirected to edit patient form on first login. Once profile is saved and patient is validated show them regular patient home page
  def unmark_as_new
    user = self.user
    user.update_attribute(:new_patient, false) if self.valid? rescue nil
  end
end
