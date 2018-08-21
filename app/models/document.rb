class Document < ApplicationRecord
  belongs_to :visit

  attr_accessor :visit_id, :name, :description, :dtype, :document

  mount_uploader :document, DocumentUploader
  validates :visit_id, presence: true
# validates :document, presence: true
#  validates_integrity_of :document
#  validates_processing_of :document
end
