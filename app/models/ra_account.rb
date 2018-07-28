class RaAccount < ApplicationRecord
 
  attr_accessor :dtr_amt
	
 def dtr_amt
    tr_amt/100.0 rescue 0.0
 end
end
