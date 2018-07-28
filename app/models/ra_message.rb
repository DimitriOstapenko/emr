class RaMessage < ApplicationRecord
	default_scope -> { order(date_paid: :desc) }
	attr_accessor :damount

# Floating point, real total ra file amount
 def damount
    amount/100.0 rescue 0.0
 end
 

end
