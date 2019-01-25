class Letter < ApplicationRecord

	belongs_to :patient, inverse_of: :letters #, counter_cache: true, autosave: true

        default_scope -> { order(date: :desc) }

        validates :date, presence: true
        validates :address_to, presence: true
        validates :patient_id, presence: true
        validates :body, presence: true
  	
	after_initialize :default_values

def doctor
	Doctor.find(self.doctor_id) rescue nil
end

def patient
	Patient.find(self.patient_id) rescue nil
end

def filespec
	LETTERS_PATH.join(self.filename) rescue nil
end

def exists?
    File.exists?(self.filespec) rescue false
end

def default_values
	self.date ||= Date.today
	self.to ||= 'To Whom It May Concern'
	self.from ||= 'Clinic Management'
end

end
