class Billing < ApplicationRecord
  default_scope -> { order(visit_date: :desc) }
  attr_accessor :doc_name, :pat_name

  validates :patient_id, presence: true
  validates :doc_id, presence: true
#  validates :diag_code, presence: true
#  validates :proc_code, presence: true

  def doc_name
    doc = Doctor.find(doc_id) if doc_id
    doc.lname if doc
  end
  
  def pat_name
    pat = Patient.find(pat_code) if pat_code
    pat.full_name if pat
  end

end
