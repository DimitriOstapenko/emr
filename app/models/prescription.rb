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
  if self.meds.class == String # SQLITE arrays are strings
    YAML.load(self.meds).reject(&:empty?).map {|m| Medication.find(m)} rescue []
  else
    self.meds.reject(&:empty?).map {|m| Medication.find(m)} rescue []
  end
end

# ids of meds in medications table
def ameds
  if self.meds.class == String
    YAML.load(self.meds).reject(&:empty?) rescue [] 
  else
    self.meds.reject(&:empty?) rescue [] 
  end
end

# qty string converted to array
def aqty
  if self.qty.class == String
    YAML.load(self.qty).reject(&:empty?) rescue []
  else
    self.qty.reject(&:empty?) rescue []
  end
end

# repeats string converted to array
def arepeats
  if self.repeats.class == String
    YAML.load(self.repeats).reject(&:empty?) rescue []
  else
    self.repeats.reject(&:empty?) rescue []
  end
end

# duration string converted to array
def aduration
  if self.duration.class == String
    YAML.load(self.duration).reject(&:empty?) rescue []
  else
    self.duration.reject(&:empty?) rescue []
  end
end

end
