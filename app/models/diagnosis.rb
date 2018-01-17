class Diagnosis < ApplicationRecord

	validates :diag_code, presence: true, length: { maximum: 10 }, numericality: true, uniqueness: true
	validates :diag_descr, presence: false, length: { maximum: 100 }
	validates :prob_type, length: {maximum: 80}

end
