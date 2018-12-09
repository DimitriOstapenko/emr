class RaMessage < ApplicationRecord
	default_scope -> { order(date_paid: :desc) }
	attr_accessor :damount

# Floating point Net amout paid by MHO
 def damount
    amount/100.0 rescue 0.0
 end
 
# Floating point, sum of all claimed amounts
 def dsum_claimed
    sum_claimed/100.0 rescue 0.0
 end
 
# Floating point, sum of all paid amounts
 def dsum_paid
    sum_paid/100.0 rescue 0.0
 end
 
end
