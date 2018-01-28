class Visit < ApplicationRecord
  belongs_to :patient
  default_scope -> { order(created_at: :desc) }
  attr_accessor :doctor
  
  validates :patient_id, presence: true
  validates :doc_id, presence: true
#  validates :diag_code, presence: true
#  validates :proc_code, presence: true

  def doctor
    Doctor.find(doc_id)
  end
  
end
