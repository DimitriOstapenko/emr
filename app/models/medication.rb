class Medication < ApplicationRecord
      belongs_to :patient, inverse_of: :medications #, counter_cache: true, autosave: true

      default_scope -> { order(active: :desc, date: :desc) }

      validates :patient_id, presence: true
      validates :name, presence: true
      validates :dose, presence: true
      validates :date, presence: true

      after_initialize :default_values
      attr_accessor :generic_name

  def patient
    Patient.find(self.patient_id) rescue nil
  end

  def doctor
    Doctor.find(self.doctor_id) rescue nil
  end

  def active_str
	  self.active? ? 'Yes':'No'
  end

  def default_values
    self.date ||= Date.today
  end
	
end
