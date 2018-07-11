class Service < ApplicationRecord
	belongs_to :claim, inverse_of: :services
end
