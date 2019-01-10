class Prescription < ApplicationRecord
	belongs_to :patient, inverse_of: :prescriptions
#	has_and_belongs_to_many :medications
	default_scope -> { order(visit_id: :desc) }


def visit
  Visit.find(self.visit_id) if self.visit_id
end

def patient
  Patient.find(self.patient_id)
end

def doctor
  Doctor.find(self.doctor_id)
end

def date
  self.created_at || Date.today
end

def filespec
  PRESCRIPTIONS_PATH.join(filename) rescue nil
end

# Is PDF file present?
def pdf_present?
  self.filespec && File.exists?(self.filespec)	
end

# List of objects
def med_list
# SQLITE arrays are strings, PG arrays are arrays
#  if self.meds.class == String 
#    YAML.load(self.meds).reject(&:empty?).map {|m| Medication.find(m)} rescue []
#  Change next 4 procedures in case of SQLITE devel/test environment

    self.meds.reject(&:empty?).map {|m| Medication.find(m)} rescue []
end

# ids of meds in medications table
def ameds
    self.meds.reject(&:empty?) rescue [] 
end

# qty string converted to array
def aqty
    self.qty.reject(&:empty?) rescue []
end

# repeats string converted to array
def arepeats
    self.repeats.reject(&:empty?) rescue []
end

# duration string converted to array
def aduration
    self.duration.reject(&:empty?) rescue []
end

end
