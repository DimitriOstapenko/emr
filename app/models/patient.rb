class Patient < ApplicationRecord
        has_many :visits, dependent: :destroy, inverse_of: :patient
#	accepts_nested_attributes_for :visits,  :reject_if => :all_blank, :allow_destroy => true
	attr_accessor :full_name, :age, :cardstr, :phonestr
	default_scope -> { order(lname: :asc, fname: :asc) }

	before_validation { email.downcase! rescue '' }
	before_validation { self.ohip_num = ohip_num.gsub(/\D/,'') rescue '' }
	before_validation { ohip_ver.upcase! }
	before_validation { phone.gsub!(/\D/,'') rescue '' }
	before_validation { mobile.gsub!(/\D/,'') rescue '' }
	before_validation { pharm_phone.gsub!(/\D/,'')  rescue '' }
	before_validation { postal.tr!(' -','') rescue '' }
	before_validation { postal.upcase! rescue '' }

	validates :lname, presence: true, length: { maximum: 50 }
	validates :fname, :mname, length: { maximum: 50 }, allow_blank: true
	validates :ohip_num,  length: { is: 10 }, numericality: { only_integer: true }, uniqueness: true, presence:true, if: Proc.new { |a| a.hin_prov == 'ON' &&  a.pat_type == 'O'}
#!	validates :ohip_ver, presence: true, length: { maximum: 3 }, if: Proc.new { |a| a.hin_prov == 'ON' &&  a.pat_type == 'O'}
	validates :dob, presence: true
#        validates :phone, presence: true #, length: { is: 10 }, numericality: { only_integer: true }
	validates :sex, presence: true, length: { is: 1 },  inclusion: %w(M F X) 
	validates :postal, length: { is: 6 }, allow_blank: true
#        validates :mobile, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
#        validates :pharm_phone, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
	
	validate :hc_checksum_and_expiry 

  def full_name
    return fname.blank? ? lname : "#{lname}, #{fname} #{mname}"
  end

  def ohip_num_full
    return ohip_ver.blank? ? ohip_num : [ohip_num, ohip_ver].join(' ')
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
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def hc_checksum_and_expiry
# Don't validate out of province or non-ohip numbers   
    return if (hin_prov != 'ON' ||  pat_type != 'O')
    
    arr = ohip_num.split('')
    last_digit = arr[-1].to_i

    expiry = hin_expiry.to_date rescue '1900-01-01'.to_date
    if expiry < Date.today
       errors.add('Health Card:', "Card is expired") 
       return 
    end

# Check sum test is disabled for now    
    return

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

  def valid_attribute?( attribute_name )
    self.valid?
    self.errors[attribute_name].blank?
  end

end
