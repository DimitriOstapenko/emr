class Service < ApplicationRecord
	belongs_to :claim, inverse_of: :services


# Floating point, real amount submitted
def damt_subm
    (amt_subm/100).to_f rescue 0.0 
end

# Floating point, real amount paid
def damt_paid
    (amt_paid/100).to_f rescue 0.0 
end

end
