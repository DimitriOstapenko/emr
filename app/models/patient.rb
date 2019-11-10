class Patient < ApplicationRecord
        has_many :visits, dependent: :destroy #, inverse_of: :patient
	has_many :doctors, through: :visits

        has_many :invoices, dependent: :destroy, inverse_of: :patient
        has_many :letters, dependent: :destroy, inverse_of: :patient
        has_many :referrals, dependent: :destroy, inverse_of: :patient
        has_many :medications, dependent: :destroy, inverse_of: :patient
        has_many :prescriptions, dependent: :destroy, inverse_of: :patient
        has_one :chart, inverse_of: :patient

  	accepts_nested_attributes_for :invoices, :allow_destroy => false, reject_if: proc { |attributes| attributes['filespec'].blank? }
  	accepts_nested_attributes_for :letters, :allow_destroy => false, reject_if: proc { |attributes| attributes['filespec'].blank? }
  	accepts_nested_attributes_for :referrals, :allow_destroy => false, reject_if: proc { |attributes| attributes['filespec'].blank? }
#	accepts_nested_attributes_for :visits,  :reject_if => :all_blank, :allow_destroy => true
	attr_accessor :full_name, :age, :cardstr, :phonestr
	default_scope -> { order(lname: :asc, fname: :asc) }

	before_validation { email.downcase! rescue '' }
	before_validation { self.ohip_num = ohip_num.gsub(/\D/,'') rescue nil }
	before_validation { phone.gsub!(/\D/,'') rescue '' }
	before_validation { mobile.gsub!(/\D/,'') rescue '' }
	before_validation { pharm_phone.gsub!(/\D/,'')  rescue '' }
	before_validation { postal.tr!(' -','') rescue '' }
	before_validation { ohip_ver.strip! rescue '' }
	before_validation { fname.strip!.gsub!(/\s+/,' ') rescue '' }
	before_validation { lname.strip!.gsub!(/\s+/,' ') rescue '' }
	before_validation :upcase_some_fields 

	# Force Patient to RMB if province is not ON, to HCP if province is ON when HC number present	
	before_save { self.pat_type = 'O' if self.ohip_num.present? && self.hin_prov == 'ON' && self.pat_type == 'R';
		      self.pat_type = 'R' if self.ohip_num.present? && self.hin_prov != 'ON' && self.pat_type == 'O'; }

	validates :pat_type, presence: true, length: { is: 1 }
	validates :lname, presence: true, length: { maximum: 50 }
	validates :fname, :mname, length: { maximum: 50 }, allow_blank: true
	validates :ohip_num,  presence:true, length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true,
		  if: Proc.new { |a| (a.hin_prov == 'ON' &&  a.pat_type == 'O') || (a.hin_prov != 'ON' &&  a.pat_type == 'R')}
	validates :ifh_number,  presence:true, length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true,
		  if: Proc.new { |a| (a.pat_type == 'I')}
	validates :ohip_ver, length: { maximum: 2 }, if: Proc.new { |a| a.hin_prov == 'ON' &&  a.pat_type == 'O'}
	validates :dob, presence: true
#        validates :phone, presence: true #, length: { is: 10 }, numericality: { only_integer: true }
	validates :sex, presence: true, length: { is: 1 },  inclusion: %w(M F X) 
	validates :postal, length: { is: 6 }, allow_blank: true
#        validates :mobile, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
#        validates :pharm_phone, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
	
	validate :hc_expiry 
	validate :validate_age

  def full_name
    fname.blank? ? lname : "#{lname}, #{fname} #{mname}"
  end
 
# Use single underscore instead of multiple blanks, no middle name
  def full_name_norm
    ln = lname.strip.gsub(/\s+/,'_') rescue ''
    fn = fname.strip.gsub(/\s+/,'_') rescue ''
    fname.blank? ? ln : "#{ln},#{fn}"
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

# Formatted phone number
  def phonestr
    ActiveSupport::NumberHelper.number_to_phone(phone, area_code: :true)
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

  def hc_expiry
   return unless self.ohip_num.present? && self.ohip_ver.present?
# Don't validate out of province or non-ohip numbers   
    if (hin_prov == 'ON' &&  pat_type == 'O')
      if hin_expiry.blank?
         errors.add('Health Card:', "Expiry date is required")
	 return
      end
      expiry = hin_expiry.to_date rescue '1900-01-01'.to_date
      errors.add('Health Card:', "Card is expired") if expiry < Date.today
      errors.add('Health Card:', "Card number for ON must be 10 digits long") if ohip_num.present? && ohip_num.length != 10
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
    errors.add('OHIP patient:', "Verifying Health Card number") 
    errors.add('Ontario Health Card:', "Number is invalid") 
  end

  def chart_filespec
	 CHARTS_PATH.join(self.chart_file)
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

protected

  def upcase_some_fields
	  ohip_ver.upcase! if ohip_ver.present?
	  postal.upcase! if postal.present?
	  lname.upcase! if lname.present?
	  fname.upcase! if fname.present?
	  mname.upcase! if mname.present?
	  maid_name.upcase! if maid_name.present?
  end

  def validate_age
      return unless dob.present?
      if dob < 120.years.ago || dob > Date.yesterday
          errors.add('Error:', 'Date of birth is out of range')
      end
  end


end
