class Referral < ApplicationRecord
	belongs_to :patient, inverse_of: :referrals #, counter_cache: true, autosave: true

        default_scope -> { order(date: :desc) }

        validates :date, presence: true
        validates :address_to, presence: true
        validates :patient_id, presence: true
        validates :reason, presence: true
        validates :to_phone, presence: true
        validates :to_doctor_id, presence: true

        after_initialize :default_values

def doctor
        Doctor.find(self.doctor_id) rescue nil
end

def to_doctor
        Doctor.find(self.to_doctor_id) rescue nil
end

def patient
        Patient.find(self.patient_id) rescue nil
end

def filespec
        REFERRALS_PATH.join(self.filename) rescue nil
end

def exists?
    File.exists?(self.filespec) rescue false
end

def default_values
        self.date ||= Date.today
end


end
