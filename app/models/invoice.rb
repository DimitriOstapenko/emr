class Invoice < ApplicationRecord
	
	default_scope -> { order(date: :desc) }

	validates :date, presence: true
	validates :billto, presence: true, numericality: { only_integer: true }
	validates :patient_id, presence: true
	validates :amount, presence: true, numericality: true
end
