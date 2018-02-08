class Procedure < ApplicationRecord
        default_scope -> {order(code: :asc)}
        
	validates :code, presence: true, length: { maximum: 10 }, uniqueness: { case_sensitive: false }
#        validates :qcode, length: { maximum: 50 }
	validates :ptype, presence: true, length: { maximum: 5 }
	validates :descr, length: { maximum: 100 }, presence: true
	validates :cost, presence: true, numericality: {greater_than_or_equal_to: 0} 
	validates :unit, presence: true, inclusion: { in: 0..20 }
	validates :fac_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :adm_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :diag_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :ref_req, inclusion: { in: [true, false] }, allow_blank: true
	validates :percent, numericality: true, allow_blank: true 
#	validates :eff_date, allow_nil: true
#	validates :term_date, allow_nil: true
	
end


