class Patient < ApplicationRecord
        has_many :visits, dependent: :destroy
	attr_accessor :full_name, :age
	default_scope -> {order(lname: :asc)}

	validates :lname, presence: true, length: { maximum: 50 }
	validates :fname, length: { maximum: 50 }
	validates :mname, length: { maximum: 50 }, allow_blank: true
#	validates :ohip_num,  length: { is: 10 }, numericality: { only_integer: true }, uniqueness: true, allow_blank: true
#	validates :dob, presence: true
#       validates :phone, presence: true # , length: { is: 10 }, numericality: { only_integer: true }
	validates :sex, presence: true, length: { is: 1 },  inclusion: %w(M F X) 
#	validates :ohip_ver, presence: true


  def full_name
    return fname.blank? ? lname : [lname, fname].join(', ')
  end

  def age
    return unless dob
    now = Date.today
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  
# scope :cifind_by, lambda { |attribute, value| where("lower(#{attribute}) = ?", value.downcase) }

end
