class Patient < ApplicationRecord
        has_many :visits, dependent: :destroy, inverse_of: :patient
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
	before_validation :upcase_some_fields 

	validates :pat_type, presence: true, length: { is: 1 }
	validates :lname, presence: true, length: { maximum: 50 }
	validates :fname, :mname, length: { maximum: 50 }, allow_blank: true
	validates :ohip_num,  length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true, presence:true, 
		  if: Proc.new { |a| (a.hin_prov == 'ON' &&  a.pat_type == 'O') || (a.hin_prov != 'ON' &&  a.pat_type == 'R')}
	validates :ifh_number,  length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true, presence:true, 
		  if: Proc.new { |a| (a.pat_type == 'I')}
	validates :ohip_ver, length: { maximum: 2 }, if: Proc.new { |a| a.hin_prov == 'ON' &&  a.pat_type == 'O'}
	validates :dob, presence: true
#        validates :phone, presence: true #, length: { is: 10 }, numericality: { only_integer: true }
	validates :sex, presence: true, length: { is: 1 },  inclusion: %w(M F X) 
	validates :postal, length: { is: 6 }, allow_blank: true
#        validates :mobile, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
#        validates :pharm_phone, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
	
	validate :hc_expiry 

  def full_name
    return fname.blank? ? lname : "#{lname}, #{fname} #{mname}"
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

  def age
    return unless dob
    now = Date.today
    years = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    years > 0 ? years : (dob.year * 12 + dob.month) - (now.year * 12 + now.month) 
  end

  def age_str
    return '' unless age
    age > 0 ? "#{age} yr" : "#{-age} mo" 	  
  end

  def hc_expiry

# Don't validate out of province or non-ohip numbers   
    if (hin_prov == 'ON' &&  pat_type == 'O')
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

#  def valid_attribute?( attribute_name )
#   self.valid?
#   self.errors[attribute_name].blank?
#  end

protected

  def upcase_some_fields
	  ohip_ver.upcase! if ohip_ver.present?
	  postal.upcase! if postal.present?
	  lname.upcase! if lname.present?
	  fname.upcase! if fname.present?
	  mname.upcase! if mname.present?
	  maid_name.upcase! if maid_name.present?
  end

end
