class Invoice < ApplicationRecord
	
	default_scope -> { order(date: :desc) }

	validates :visit_id, presence: true, uniqueness: true, numericality: { only_integer: true }
	validates :date, presence: true
	validates :billto, presence: true, numericality: { only_integer: true }
end
