class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits #, counter_cache: true, autosave: true
  has_many :documents, dependent: :destroy, inverse_of: :visit
  accepts_nested_attributes_for :documents, :allow_destroy => true, reject_if: proc { |attributes| attributes['document'].blank? }
  
  mount_uploader :document, DocumentUploader

  default_scope -> { order(entry_ts: :desc) }
  attr_accessor :doctor, :proc_codes, :bil_types, :total_fee, :diag_scode
  
  validates :patient_id, presence: true, numericality: { only_integer: true }
  validates :doc_id, presence: true
#  validates :doc_code, presence: true
#  validates :diag_code, presence: true, numericality: true, length: { maximum: 10 }
  validates :proc_code, length: { maximum: 10 }
  validates :proc_code2, length: { maximum: 10 }
  validates :proc_code3, length: { maximum: 10 }
  validates :proc_code4, length: { maximum: 10 }
#  validates :units, numericality: { only_integer: true, only_positive: true }
#  validates :units2, numericality: { only_integer: true, only_positive: true }
#  validates :units3, numericality: { only_integer: true, only_positive: true }
#  validates :units4, numericality: { only_integer: true, only_positive: true }
#  validates :duration, numericality: { only_integer: true, only_positive: true }
  validates :entry_ts, presence: true

  validate :diag_required
  after_initialize :default_values

  def default_values
	  self.entry_ts ||= Time.now
	  self.status ||= ARRIVED
	  self.units ||= 1
	  self.vis_type ||= WALKIN_VISIT
	  self.duration ||= 10
  end

  def doctor
    Doctor.find(doc_id) rescue Doctor.new 
  end

  def pat
    Patient.find(patient_id) rescue Patient.new 
  end

# Symbol for patient's type (:HCP,:WCB...)  
  def pat_btype
    PATIENT_TYPES.invert[pat.pat_type]
  end

  def date 
    entry_ts.to_date rescue '1900-01-01'
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
    bil_types('').index(BILLING_TYPES[:Cash].to_s) ||
    bil_types('').index(BILLING_TYPES[:PRV].to_s)
  end  

# Are there HCP services in this visit?
  def hcp_services?
      !hcp_proc_codes.empty?
  end

# Invoiced service? (first service is invoice)
  def invoiced?
    bil_types('').index(INVOICE_BILLING.to_s) == 0
  end

# Cash only service? (first service is cash) 
  def cash?
#    bil_types('').index(BILLING_TYPES[:Cash].to_s) && 1
    bil_types('').index(CASH_BILLING.to_s) == 0
  end

# Is visit ready to bill?
  def ready_to_bill?
    status == READY
  end  

# Is visit paid for?
  def paid?
    status == PAID
  end  

# Is visit billed or paid for?  
  def billed_or_paid?
    status == PAID || status == BILLED
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

# array of all units  
  def all_units
    services.map{|el| el[:units]}  
  end

# array of all proc codes
  def all_pcodes
    services.map{|el| el[:pcode]}  
  end

# array of all bill types (strings)
  def all_btypes_str
    services.map{|el| BILLING_TYPES.invert[el[:btype]].to_s}
  end

# array of all fees
  def all_fees
    services.map{|el| el[:fee]}
  end

# Total fee for this visit  
  def total_fee
    fee + fee2 + fee3 + fee4
  end

# Total fee of insured services (HCP, RMB) 
  def total_insured_fees
    services.select{|i| i[:btype] && i[:btype] < CASH_BILLING}.sum{|s| s[:fee]} rescue 0
  end

# Total number of insured services (HCP, RMB) 
  def total_insured_services
    services.select{|i| i[:btype] && i[:btype] < CASH_BILLING}.count rescue 0
  end

# Total number of cash services
  def total_cash_services
    services.select{|i| i[:btype] && i[:btype] == CASH_BILLING}.count rescue 0
  end

# Total amount of cash 
  def total_cash
    services.select{|i| i[:btype] && i[:btype] == CASH_BILLING}.sum{|s| s[:fee]} rescue 0
  end

# Total number of IFH services 
  def total_ifh_services
    services.select{|i| i[:btype] && i[:btype] == IFH_BILLING}.count rescue 0
  end

# Total number of WCB services 
  def total_wcb_services
    services.select{|i| i[:btype] && i[:btype] == WCB_BILLING}.count rescue 0
  end

# Total number of RMB services 
  def total_rmb_services
    services.select{|i| i[:btype] && i[:btype] == RMB_BILLING}.count rescue 0
  end

# Total of other than insured services   
  def total_non_insured_fees
    total_fee - total_insured_fees
  end

  def invoice_amount  
     serv  = services[_3rd_index]
     serv[:fee] > 1 ? serv[:fee] : amount
  end
  
  def invoice_units  
     serv  = services[_3rd_index]
     serv[:units] rescue 0
  end

  def invoice_pcode 
     serv  = services[_3rd_index]
     serv[:pcode] rescue 0
  end
  
  def invoice_pdescr 
     pcode = invoice_pcode
     if pcode == 'INVOICE'
	reason
     else
	proc_descr( invoice_pcode )
     end
  end

# Short version of diagnostic code
  def diag_scode
	  diag_code[0,3].rjust(3,'0') if diag_code.present?
  end

# Return diagnosis description
  def diag_descr
    diag = Diagnosis.find_by(code: diag_code )	  
    return diag.descr rescue '' 
  end

# Return procedure description
  def proc_descr ( code = proc_code )
    proc = Procedure.find_by(code: code )	  
    return proc.descr rescue '' 
  end

  def status_str
	  VISIT_STATUSES.invert[status].to_s rescue ''
  end

  def bil_type_str
	  BILLING_TYPES.invert[bil_type].to_s rescue ''
  end
  
  def bil_type2_str
	  BILLING_TYPES.invert[bil_type2].to_s
  end
  
  def bil_type3_str
	  BILLING_TYPES.invert[bil_type3].to_s
  end
  
  def bil_type4_str
	  BILLING_TYPES.invert[bil_type4].to_s
  end

  def was_today?
     entry_ts.to_date == Date.today
  end

  def diag_required
    hcp_codes = hcp_proc_codes.split(',') rescue nil
    return unless hcp_codes.any?
    hcp_codes.each do |code|
      proc = Procedure.find_by(code: code)      
      if proc.diag_req
	      errors.add('Error:', "Diagnosis is required for this visit") if diag_code.blank?
         return
      end
    end
  end

  def has_proc?(code)
    hcp_codes = hcp_proc_codes.split(',') rescue nil
    return unless hcp_codes.any?
    hcp_codes.index(code)
  end

end


