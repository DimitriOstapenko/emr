class Billing < ApplicationRecord
 
  default_scope -> { order(visit_date: :desc) }
  attr_accessor :doc_name, :pat_name

  validates :pat_id, presence: true
  validates :doc_code, presence: true
#!validates :doc_id, presence: true
#!  validates :diag_code, presence: true
  validates :proc_code, presence: true
  validates :visit_id, presence: true
#!  validates :visit_date, presence: true
  validates :fee, presence: true

  def doc_name
    doc = Doctor.find(doc_id) if doc_id
    doc.lname if doc
  end
  
  def pat_name
    pat = Patient.find(pat_id) if pat_id
    pat.full_name if pat
  end

  def self.any_errors?
    Visit.where(status: ERROR).any? rescue false
  end

end
