class Patient < ApplicationRecord
	attr_accessor :full_name, :age, :sex_str
	validates :lname, presence: true, length: { maximum: 50 }
	validates :fname, presence: true, length: { maximum: 50 }
	validates :ohip_num, presence: true, length: { is: 10 },
	           numericality: { only_integer: true },
                   uniqueness: { case_sensitive: false }
	validates :dob, presence: true
	validates :phone, presence: true, length: { is: 10 },
	           numericality: { only_integer: true }

  def full_name
    [fname, lname].join(', ')
  end

  def age
    now = Date.today
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def sex_str
      ssex = {1 =>'M', 2=>'F'}
      ssex[sex]
  end

end
