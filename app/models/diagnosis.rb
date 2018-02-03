class Diagnosis < ApplicationRecord

	default_scope -> { order(code: :asc) }

	validates :code, presence: true, length: { maximum: 10 }, numericality: true, uniqueness: true
	validates :descr, presence: false, length: { maximum: 100 }
	validates :prob_type, length: {maximum: 80}

end
