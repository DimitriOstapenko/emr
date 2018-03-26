class Vaccine < ApplicationRecord

	default_scope -> { order(name: :asc) }

	before_validation { name.strip! rescue '' }
	before_validation { target.strip! rescue '' }

	validates :name, uniqueness: true, presence:true
end
