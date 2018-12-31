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
  Date.today
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
  YAML.load(self.meds).reject(&:empty?).map {|m| Medication.find(m)} rescue []
end

# meds column string converted to array (ids of meds in medications table)
def ameds
  YAML.load(self.meds).reject(&:empty?) rescue [] 
end

# qty string converted to array
def aqty
  YAML.load(self.qty).reject(&:empty?) rescue []
end

# repeats string converted to array
def arepeats
  YAML.load(self.repeats).reject(&:empty?) rescue []
end

# duration string converted to array
def aduration
  YAML.load(self.duration).reject(&:empty?) rescue []
end

private 

end
