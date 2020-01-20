class PatientDoc < ApplicationRecord

        belongs_to :patient, inverse_of: :patient_docs #, counter_cache: true, autosave: true
        belongs_to :doctor, inverse_of: :patient_docs 

        default_scope -> { includes(:doctor).order(date: :desc) }

        validates :date, presence: true
        validates :doc_type, presence: true, numericality: { only_integer: true}
        validates :doctor_id, presence: true

        after_initialize :default_values

        mount_uploader :patient_doc, DocumentUploader

def doc_type_str
  PATIENT_DOC_TYPES.invert[self.doc_type] rescue ''
end  

def filename
  self.patient_doc_identifier
end

# absolute pathname
def filespec
    self.patient_doc.path rescue nil
end

def exists?
    File.exists?(self.filespec) rescue false
end

def default_values
  self.date ||= Date.today
end

end
