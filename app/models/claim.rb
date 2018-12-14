class Claim < ApplicationRecord
	has_many :services, dependent: :destroy, inverse_of: :claim
	default_scope -> { joins(:services).reorder('svc_date desc') }
	attr_accessor :amt_subm, :amt_paid, :damt_subm, :damt_paid, :date, :svcs

# Total claim amount submitted (integer)
 def amt_subm
   services.sum(:amt_subm)
 end 

# Total claim amount billed (integer) 
 def amt_paid
   services.sum(:amt_paid)
 end

# Paid and claimed amounts are not equal
 def amt_mismatched?
   amt_paid != amt_subm
 end 
 
# Floating point, real total claim amount submitted
 def damt_subm
   amt_subm.to_f/100 rescue 0.0
 end 

# Floating point, real total claim amount paid
 def damt_paid 
   amt_paid.to_f/100 rescue 0.0
 end 

# Visit date, from the first service 
 def date
   services.first.svc_date rescue nil
 end

# Number of servicies in this claim 
 def svcs
   services.size
 end

# First error if any 
 def errcode
   services.first.errcode 
 end
end
