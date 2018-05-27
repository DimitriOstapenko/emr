class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits #, counter_cache: true, autosave: true
  default_scope -> { order(created_at: :desc) }
  attr_accessor :doctor, :proc_codes, :bil_types, :total_fee, :diag_scode #, :diag_descr, :proc_descr, :_3rd_index, :services, :invoiced?, :cash?
  
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

# all procedure codes for this visit
  def proc_codes(sep=',')
    [proc_code, proc_code2, proc_code3, proc_code4].reject(&:blank?).join(sep)
  end

# hcp procedure codes for this visit
  def hcp_proc_codes(sep = ',')  
    [proc_code, proc_code2, proc_code3, proc_code4].grep(/^[[:upper:]]\d{3}[[:upper:]]$/).join(sep)   # A007A consider as HCP
  end
 
# all billing types for procedures for this visit
  def bil_types ( sep = ',' )
    [bil_type, bil_type2, bil_type3, bil_type4].reject(&:blank?).join(sep)
  end
  
# Find index of 3-rd party procedure in the list of procedures, if any
  def _3rd_index
    bil_types('').index(BILLING_TYPES[:Invoice].to_s) ||
    bil_types('').index(BILLING_TYPES[:Cash].to_s)
  end  

# Are there HCP services in this visit?
  def hcp_services?
      !hcp_proc_codes.empty?
  end

# Is there invoiced service
  def invoiced?
    bil_types('').index(BILLING_TYPES[:Invoice].to_s) && 1
  end

# Is there cash service?
  def cash?
    bil_types('').index(BILLING_TYPES[:Cash].to_s) && 1
  end

# Is visit ready to bill?
  def ready_to_bill?
    status == 3
  end  

# Service array to help deal with procedures/billings
  def services   
    serv = []
    if !proc_code.blank?
       serv.push({pcode: proc_code,  units: units,  btype: bil_type,  fee: fee})
    end
    if !proc_code2.blank?
       serv.push({pcode: proc_code2, units: units2, btype: bil_type2, fee: fee2})
    end
    if !proc_code3.blank?
       serv.push({pcode: proc_code3, units: units3, btype: bil_type3, fee: fee3})
    end
    if !proc_code4.blank?
       serv.push({pcode: proc_code4, units: units4, btype: bil_type4, fee: fee4})
    end
    return serv
  end

# Total fee for this visit  
  def total_fee
    fee*units + fee2*units2 + fee3*units3 + fee4*units4
  end

  def invoice_amount  
     serv  = services[_3rd_index]
     serv[:fee] rescue 0
  end
  
  def invoice_units  
     serv  = services[_3rd_index]
     serv[:units] rescue 0
  end

  def invoice_pcode 
     serv  = services[_3rd_index]
     serv[:pcode] rescue 0
  end

# Short version of diagnostic code
  def diag_scode
      diag_code[0,3].rjust(3,'0') if !diag_code.blank?
  end

# Return diagnosis description
  def diag_descr
    diag = Diagnosis.find_by(code: diag_code )	  
    return diag.descr rescue '' 
  end

# Return procedure description
  def proc_descr ( code )
    proc = Procedure.find_by(code: code )	  
    return proc.descr rescue '' 
  end

  def status_str
    VISIT_STATUSES.invert[status]
  end

  def bil_type_str
    BILLING_TYPES.invert[bil_type]
  end
  
  def bil_type2_str
    BILLING_TYPES.invert[bil_type2]
  end
  
  def bil_type3_str
    BILLING_TYPES.invert[bil_type3]
  end
  
  def bil_type4_str
    BILLING_TYPES.invert[bil_type4]
  end

end


