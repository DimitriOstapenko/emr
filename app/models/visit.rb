class Visit < ApplicationRecord

  include My::Nexmo_phone

  belongs_to :patient, inverse_of: :visits #, counter_cache: true, autosave: true
  has_many :documents, dependent: :destroy, inverse_of: :visit
  has_one :doctor

  accepts_nested_attributes_for :documents, :allow_destroy => true, reject_if: proc { |attributes| attributes['document'].blank? }
  
#  include SessionsHelper 
#  include DoctorsHelper 
 
  mount_uploader :document, DocumentUploader

  default_scope -> { order(entry_ts: :desc) }
  attr_accessor :doctor, :proc_codes, :bil_types, :total_fee, :diag_scode
  
#  validates :patient_id, presence: true, numericality: { only_integer: true }
  validates :doc_id, presence: true
  validates :proc_code, length: { maximum: 10 }
  validates :proc_code2, length: { maximum: 10 }
  validates :proc_code3, length: { maximum: 10 }
  validates :proc_code4, length: { maximum: 10 }
  validates :entry_ts, presence: true
  validates_acceptance_of :consented, if: Proc.new { |v| (v.vis_type == 'TV')}  # For televisits only
  validates :reason, presence: true, if: Proc.new { |v| (v.vis_type == 'TV')}

  validate :diag_required
  after_initialize :default_values
  after_create :notify_doctor_and_patient, if: Proc.new { |v| (v.vis_type == 'TV')} 

# Patient type and hin_num may change from visit to visit; We won't update on other attr changes
  before_save { 
	  self.pat_type ||= pat.pat_type
          self.status = ASSESSED if (self.status == READY && self.diag_code.blank? && self.hcp_services?)
	  if self.pat_type == IFH_PATIENT
	    self.hin_num ||= pat.ifh_number
	  elsif self.pat_type == CASH_PATIENT
	    self.hin_num ||= '' 
	  else 
	    self.hin_num ||= pat.ohip_num
	  end
          if self.vis_type = 'TV'
            self.proc_code = 'K081A' 
            self.proc_code2 = 'K301A' 
          end
	  }
                
# Send email to the doctor about new Virtual visit  
  def notify_doctor_and_patient
    UserMailer.new_visit(self).deliver
    send_new_visit_sms(self)       # to patient & doctor if mobiles are present
#    voice_message_to_doctor(self)  # notify doctor about new visit 
  end

  def doctor
    Doctor.find(doc_id) rescue Doctor.new 
  end

  def pat
    Patient.find(patient_id) rescue Patient.new 
  end
  
  def patient
      self.pat || Patient.find(patient_id) rescue Patient.new 
  end

# Symbol for patient's type (:HCP,:WCB...)  
  def pat_btype
    PATIENT_TYPES.invert[pat.pat_type]
  end

  def type
    VISIT_TYPES.invert[self.vis_type]
  end

  def date 
    entry_ts.to_date rescue '1900-01-01'
  end

# Visit date string yyyymmdd (EDT)
  def date_str
     date.strftime("%Y%m%d")
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
  
# Are there HCP services in this visit?
  def hcp_services?
      !hcp_proc_codes.empty?
  end

# Visit includes cash service?
  def cash?
     self.bil_types.include?(CASH_BILLING.to_s)
  end

# Patient with the doctor?
  def with_doctor?
    status == WITH_DOCTOR
  end  

# Patient assessed, but not billed yet?
  def assessed?
    status == ASSESSED
  end  

# Is visit ready to bill?
  def ready_to_bill?
    status == READY
  end  

  def ready?
    self.ready_to_bill?
  end

# Is visit paid for?
  def paid?
    status == PAID
  end  

# Is visit billed or paid for?  
  def billed_or_paid?
    status == PAID || status == BILLED
  end  

# Does visit have error?
  def has_error?
    status == ERROR 
  end  

# Was visit cancelled?
  def cancelled?
    status == CANCELLED 
  end  

  def arrived?
    status == ARRIVED
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

# Cash services for this visit
  def cash_services 
    services.select{|i| i[:btype] && i[:btype] == CASH_BILLING} rescue []
  end

# Total number of cash services
  def total_cash_services
    cash_services.count rescue 0
  end

# String of cash proc_codes  
  def cash_pcodes  
    cash_services.map{|pc| pc[:pcode]}.join',' rescue ''
  end

# Total amount of cash 
  def total_cash
    services.select{|i| i[:btype] && i[:btype] == CASH_BILLING}.sum{|s| s[:fee]} rescue 0
  end

# Total number of IFH services 
  def total_ifh_services
    services.select{|i| i[:btype] && i[:btype] == IFH_BILLING}.count rescue 0
  end

# Total IFH fees
  def total_ifh_fees
    services.select{|i| i[:btype] && i[:btype] == IFH_BILLING}.sum{|s| s[:fee]} rescue 0
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

# Short version of diagnostic code
  def diag_scode
    diag_code[0,3].rjust(3,'0') if diag_code.present?
  end

# Return diagnosis description
  def diag_descr
    diag = Diagnosis.find_by(code: diag_code )	  
    return diag.descr rescue cash_pcodes 
  end

# Return procedure description for given code
  def proc_descr ( code = proc_code )
    proc = Procedure.find_by(code: code )	  
    return proc.descr rescue '' 
  end

  def status_str
    VISIT_STATUSES.invert[status].to_s rescue ''
  end

# Do not show patient real status
  def patient_status_str
    case self.status
      when 0
         return 'New visit' 
      when 7 
         return 'Cancelled' 
      when 3..5 
         return 'Complete'    
      else
         return 'In Process'
    end
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

# Generate error if one of the procedures requires diagnosis  
  def diag_required
    return if self.vis_type == TELE_VISIT  # patient-created visits have no diagnosis
    hcp_codes = hcp_proc_codes.split(',') rescue nil
    return unless hcp_codes.any?
    hcp_codes.each do |code|
      proc = Procedure.find_by(code: code)      
      if proc.diag_req
        errors.add(:diag_code, "Diagnosis is required for this visit") if diag_code.blank?
         return
      end
    end
  end

# Contains procedure with <code> ?  
  def has_proc?(code)
    hcp_codes = hcp_proc_codes.split(',') rescue nil
    return unless hcp_codes.any?
    hcp_codes.index(code)
  end

# Was visit billed yet?  
  def editable?
    (self.entry_ts.to_date == Date.today && self.billing_ref.blank?) || ![BILLED,PAID,CANCELLED].include?(self.status)
  end

# Consent form signed 
  def consented_str
    self.consented? ? 'Yes' : 'No' 
  end

# Meds Renewed?
  def meds_renewed_str
    self.meds_renewed? ? 'Yes' : 'No' 
  end


private 
# Can only save 1 visit per patient per doctor per day  
  def check_uniqueness 
    has_visits = pat.visits.where(doc_id: OWNER_DOC_ID).order(entry_ts: :desc).first.entry_ts.today? rescue nil  #where('date(entry_ts)=?', self.entry_ts.to_date)
    errors.add(:reason, "Only 1 visit is allowed by OHIP per patient per day") if has_visits
  end

  def default_values
	  self.entry_ts ||= Time.zone.now #.strftime("%Y-%m-%d at %H:%M")  # html5 date on mobile
	  self.status ||= ARRIVED
	  self.units ||= 1
	  self.vis_type ||= WALKIN_VISIT
          self.bil_type ||= HCP_BILLING
	  self.duration ||= 10
#          self.proc_code ||= 'K081A' # televisit!!
          self.notes ||= "Verbal consent was obtained." if self.consented?  #unless pat.user && pat.user.patient?
  end

end


