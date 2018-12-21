class Procedure < ApplicationRecord
        default_scope -> {order(code: :asc)}
        
	attr_accessor :full_name, :age, :cardstr #, :prov_fee_real, :spec_fee_real, :ana_fee_real, :non_ana_fee_real

	VALID_PCODE_REGEX = /\A[a-z]\d{3}[a-z]\z/i
	validates :code, presence: true, length: { maximum: 10 }, uniqueness: { case_sensitive: false }
	validates :code, format: { with: VALID_PCODE_REGEX, message: "for HCP procedure can only be in format <letter><3_digit_number><letter>" }, if: Proc.new { |a| (a.ptype == 1)}
	validates :ptype, presence: true, length: { maximum: 5 }
	validates :descr, length: { maximum: 100 }, presence: true
	validates :cost, presence: true, numericality: true #{greater_than_or_equal_to: 0} 
	validates :unit, presence: true, inclusion: { in: 0..20 }
	validates :fac_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :adm_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :diag_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :ref_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :percent, numericality: true, allow_blank: true 

	before_validation { code.upcase! rescue nil }
	before_validation { code.strip! rescue nil }
	
	before_save { self.prov_fee = (cost*100).to_i  }
	
def prov_fee_real
  sprintf '%.2f', prov_fee/100.0
end

def spec_fee_real
  sprintf '%.2f', spec_fee/100.0
end

def ass_fee_real
  sprintf '%.2f', ass_fee/100.0
end

def ana_fee_real
  sprintf '%.2f', ana_fee/100.0
end

def non_ana_fee_real
  sprintf '%.2f', non_ana_fee/100.0
end

# Is it HCP procedure?
def insured?
  ptype == 1 
end

# Is it cash(3rd party) procedure
def cash?
  ptype == 2
end

# Return symbol for procedure type (:HCP,:3RD)  
  def ptype_str
    PROC_TYPES.invert[self.ptype].to_s
  end

  def active_str
    active? ? 'Yes':'No'
  end

  def diag_req_str
    diag_req? ? 'Yes':'No'
  end

  def ref_req_str
    ref_req? ? 'Yes':'No'
  end

end


