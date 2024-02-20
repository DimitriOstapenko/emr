class Schedule < ApplicationRecord
	default_scope -> { order(dow: :asc, start_time: :asc) }

        validates :doctor_id, presence: true
	validates :dow, presence: true, inclusion: 0..6
        validates :start_time, presence: true
	validates :end_time, presence: true
#	validates :weeks, numericality: { only_integer: true }, inclusion: 1..4 

def doctor
    Doctor.find(self.doctor_id) rescue nil
end

def self.closing_time
    [0,6].include?(Date.today.wday) ? '1:30pm':'7:30pm'
end

def self.doc_on_duty
#    sched = self.where('end_time > ?', Time.now.in_time_zone("America/New_York")).where('start_time < ?', Time.now.in_time_zone("America/New_York")).where(dow: Time.now.in_time_zone("America/New_York").wday).first rescue nil
    sched = self.clinic_open?
    doc = Doctor.find(sched.doctor_id) if sched
    if doc.present?
      last_signin_time = (sched.end.time - 30.minutes).strftime("%I:%M %p") rescue '7:30pm'
      return "On duty at the clinic: Dr. #{doc.lname}. We accept patients until #{last_signin_time}"
    else 
      return "Clinic is now closed: Please check the schedule here"
    end
end

# Returns matching row in schedule if found
def self.clinic_open?
  now = Time.now - 6.hours
  dow = Time.now.in_time_zone("America/New_York").wday 
  self.where('end_time > ?', now).where('start_time < ?', now).where(dow: dow).first rescue false
end

def from
    self.start_time.strftime("%l:%M%p")
end

def to
    self.end_time.strftime("%l:%M%p")
end


end
