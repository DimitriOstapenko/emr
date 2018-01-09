class Visit < ApplicationRecord
  belongs_to :patient
  default_scope -> { order(created_at: :desc) }

  validates :patient_id, presence: true
  validates :date, presence: true
  validates :diag_code, presence: true
  validates :proc_code, presence: true
end
