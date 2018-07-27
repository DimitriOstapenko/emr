class Service < ApplicationRecord
	belongs_to :claim, inverse_of: :services
        attr_accessor :damt_subm, :damt_paid 

# Floating point, real amount submitted
def damt_subm
	amt_subm/100.0 rescue 0.0 
end

# Floating point, real amount paid
def damt_paid
	amt_paid/100.0 rescue 0.0 
end

end
