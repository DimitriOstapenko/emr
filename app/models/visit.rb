class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits, counter_cache: true, autosave: true
#  accepts_nested_attributes_for :patient, :reject_if => :all_blank, :allow_destroy => true
  default_scope -> { order(created_at: :desc) }
  attr_accessor :doctor, :proc_codes, :total_fee, :status_str
  
  validates :patient_id, presence: true, numericality: { only_integer: true }
  validates :doc_id, presence: true, numericality: { only_integer: true }
#  validates :doc_code, presence: true
#!  validates :diag_code, presence: true, numericality: true, length: { maximum: 10 }
  validates :proc_code, presence: true, length: { maximum: 10 }
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

  def proc_codes
    codes = [proc_code, proc_code2, proc_code3, proc_code4]
    return codes.join(',')
  end

  def total_fee
	  fee + fee2 + fee3 + fee4
  end

  def status_str
	  return $statuses[status-1][0] if status.between?(1,4)
  end

end
