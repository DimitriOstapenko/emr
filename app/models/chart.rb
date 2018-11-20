class Chart < ApplicationRecord
	belongs_to :patient
	default_scope -> { order(filename: :asc) }

        validates :filename, presence: true, length: { maximum: 64 }, uniqueness: true
        validates :pages, numericality: { only_integer: true }, allow_blank: true
        validates :patient_id, presence: true, numericality: { only_integer: true } 

def patient
	Patient.find(self.patient_id) rescue nil
end	

def doctor
  Doctor.find(self.doctor_id) rescue nil
end	

def filespec
  CHARTS_PATH.join(filename) rescue nil
end

def filesize
  sprintf("%.2f", File.size(self.filespec).to_f/2**20) rescue 0
end

end
