class Patient < ApplicationRecord
	attr_accessor :full_name
	validates :lname, presence: true, length: { maximum: 50 }
	validates :fname, presence: true, length: { maximum: 50 }
	validates :ohip_num, presence: true, length: { is: 10 }, numericality: { only_integer: true }
	validates :dob, presence: true

def full_name
    [fname, lname].join(', ')
end

end
