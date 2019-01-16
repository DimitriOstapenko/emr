class MedFormat < ApplicationRecord
	default_scope -> { order(name: :asc) }
	
	validates :name,  presence: true, length: { maximum: 32 }
end
