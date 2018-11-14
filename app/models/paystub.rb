class Paystub < ApplicationRecord

	default_scope -> { order(id: :desc ) }
	attr_accessor :doctor, :filespec

        validates :doc_id, numericality: { only_integer: true }, presence: true
        validates :year, presence: true, numericality: { only_integer: true }
        validates :month, presence: true, numericality: { only_integer: true }
	
	before_save  :set_amounts
	before_create  :delete_dup_stub

  def doctor
	  Doctor.find(doc_id) rescue Doctor.new 
  end

  def non_ohip_amt
    net_amt - ohip_amt rescue 0
  end
  
  def filespec
	  PAYSTUBS_PATH.join(filename) rescue nil
  end
  
  def clinic_deduction
      (self.gross_amt / 100.0) * doctor.percent_deduction	  
  end

# Paystub month, year string
  def mon_year_str
     Date.new(self.year, self.month).strftime("%B %Y") rescue ''
  end

  private

  def set_amounts
    self.ohip_amt ||= 0
    errors.add('Paystub error:', "% Deduction not defined for this doctor") unless doctor.percent_deduction.present?
    errors.add('Paystub error:', "MHO deduction not defined for this doctor") unless self.mho_deduction.present?
    other_income = self.cash_amt + self.ifh_amt + self.hc_dep_amt + self.wcb_amt
    self.gross_amt = self.ohip_amt + other_income + self.monthly_premium_amt
    self.clinic_deduction = (self.gross_amt / 100.0) * doctor.percent_deduction	  
    self.net_amt = self.gross_amt - self.clinic_deduction - other_income  - self.mho_deduction 
  end

  def delete_dup_stub
    prev_paystub = Paystub.find_by(month: self.month, year: self.year, doc_id: self.doc_id)
    prev_paystub.destroy! if prev_paystub.present?
  end

end
