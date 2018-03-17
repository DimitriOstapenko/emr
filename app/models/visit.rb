class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits #, counter_cache: true, autosave: true
  default_scope -> { order(created_at: :desc) }
  attr_accessor :doctor, :proc_codes, :bil_types, :total_fee, :diag_scode, :diag_descr, :_3rd_index, :services
  
  validates :patient_id, presence: true, numericality: { only_integer: true }
  validates :doc_id, presence: true, numericality: { only_integer: true }
#  validates :doc_code, presence: true
#!  validates :diag_code, presence: true, numericality: true, length: { maximum: 10 }
  validates :proc_code, length: { maximum: 10 }
  validates :proc_code2, length: { maximum: 10 }
  validates :proc_code3, length: { maximum: 10 }
  validates :proc_code4, length: { maximum: 10 }
  validates :units, numericality: { only_integer: true, only_positive: true }
  validates :units2, numericality: { only_integer: true, only_positive: true }
  validates :units3, numericality: { only_integer: true, only_positive: true }
  validates :units4, numericality: { only_integer: true, only_positive: true }
  validates :duration, numericality: { only_integer: true, only_positive: true }
  validates :entry_ts, presence: true

  def doctor
    Doctor.find(doc_id) rescue Doctor.new 
  end

# all procedure codes for this visit, comma delimited
  def proc_codes
    [proc_code, proc_code2, proc_code3, proc_code4].reject(&:blank?).join(',')
  end
 
# all billing types for procedures for this visit, comma delimited
  def bil_types ( sep = ',' )
    [bil_type, bil_type2, bil_type3, bil_type4].reject(&:blank?).join(sep)
  end
  
# Find index of 3-rd party procedure in the list of procedures, if any
  def _3rd_index
    bil_types('').index(BILLING_TYPES[:"3RD"].to_s)
  end  

# Service array to help deal with procedures/billings
  def services   
    [{pcode: proc_code,  units: units,  btype: bil_type,  fee: fee}, 
     {pcode: proc_code2, units: units2, btype: bil_type2, fee: fee2},
     {pcode: proc_code3, units: units3, btype: bil_type3, fee: fee3},
     {pcode: proc_code4, units: units4, btype: bil_type4, fee: fee4}]
  end

# Total fee for this visit  
  def total_fee
    fee*units + fee2*units2 + fee3*units3 + fee4*units4
  end

# Short version of diagnostic code
  def diag_scode
    diag_code[0,3]
  end

# Return diagnosis description
  def diag_descr
    diag = Diagnosis.find_by(code: diag_code )	  
    return diag.descr rescue '' 
  end

  def status_str
    VISIT_STATUSES.invert[status]
  end
end
