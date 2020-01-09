class SpecReport < ApplicationRecord

        belongs_to :patient, inverse_of: :spec_reports #, counter_cache: true, autosave: true
        belongs_to :doctor, inverse_of: :spec_reports 

        default_scope -> { includes(:doctor).order(date: :desc) }

        validates :date, presence: true
        validates :doctor_id, presence: true

        after_initialize :default_values

        mount_uploader :filename, DocumentUploader

# absolute pathname
def filespec
    self.filename.path rescue nil
end

def exists?
    File.exists?(self.filespec) rescue false
end

def default_values
  self.date ||= Date.today
end

end
