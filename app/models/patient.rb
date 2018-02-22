class Patient < ApplicationRecord
        has_many :visits, dependent: :destroy
	accepts_nested_attributes_for :visits,  :reject_if => :all_blank, :allow_destroy => true
	attr_accessor :full_name, :age, :cardstr
	default_scope -> { order(lname: :asc) }

	before_validation { email.downcase! rescue '' }
        before_validation { ohip_num.tr!('- ','') }
	before_validation { ohip_ver.upcase! }
	before_validation { phone.tr!('- ','') }
	before_validation { mobile.tr!('- ','') rescue '' }
	before_validation { pharm_phone.tr!('- ','')  rescue '' }
	before_validation { postal.tr!('- ','') rescue '' }
	before_validation { postal.upcase! rescue '' }

	validates :lname, presence: true, length: { maximum: 50 }
	validates :fname, length: { maximum: 50 }
	validates :mname, length: { maximum: 50 }, allow_blank: true
	validates :ohip_num,  length: { is: 10 }, numericality: { only_integer: true }, uniqueness: true, presence:true #add validate_hnum here (defined below)
	validates :ohip_ver, presence: true, length: { maximum: 3 }
	validates :dob, presence: true
        validates :phone, presence: true #, length: { is: 10 }, numericality: { only_integer: true }
#        validates :mobile, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
#        validates :pharm_phone, length: { is: 10 }, numericality: { only_integer: true }, allow_blank: true
	validates :sex, presence: true, length: { is: 1 },  inclusion: %w(M F X) 
	validates :postal, length: { is: 6 }, allow_blank: true

  def full_name
    return fname.blank? ? lname : [lname, fname].join(', ')
  end

  def age
    return unless dob
    now = Date.today
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def validate_hnum (number)
    arr = number.split('')
    last_digit = arr[-1].to_i

    def sumDigits(num, base = 10)
       num.to_s(base).split(//).inject(0) {|z, x| z + x.to_i(base)}
    end

    sum = 0
    arr[0..arr.length-2].each_with_index do |dig, i|
        sum += i.odd? ? dig.to_i : sumDigits(dig.to_i * 2)
    end

    return if (last_digit == (10 - sum.to_s[-1].to_i))
    errors[:base] << "Health Card number faild checksum test"
  end

#  def get_last_visit_date
#	  v = Visit.where("pat_id = ?", id).limit(1)
# 	  return v[0].entry_ts if v
#  end

  
# scope :cifind_by, lambda { |attribute, value| where("lower(#{attribute}) = ?", value.downcase) }

end
