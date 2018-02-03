class Visit < ApplicationRecord
  belongs_to :patient
  accepts_nested_attributes_for :patient, :reject_if => :all_blank, :allow_destroy => true
  default_scope -> { order(created_at: :desc) }
  attr_accessor :doctor
  
  validates :patient_id, presence: true
  validates :doc_id, presence: true
  validates :diag_code, presence: true
  validates :proc_code, presence: true
  validates :entry_ts, presence: true

  def doctor
    Doctor.find(doc_id)
  end
  
end
