class Claim < ApplicationRecord
	has_many :services, dependent: :destroy, inverse_of: :claim
end
