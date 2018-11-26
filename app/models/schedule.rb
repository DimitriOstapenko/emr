class Schedule < ApplicationRecord
	default_scope -> { order(dow: :asc) }

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
    now = Time.now.to_i
    opening = '9:00AM'.to_time.to_i
    closing = self.closing_time.to_time.to_i	
    midnight = ('0:01AM'.to_time + 1.day).to_i
    schedule_today = Schedule.where(dow: Date.today.wday)
    docs = schedule_today.map{|s| s.doctor.lname}.join',' if schedule_today.any?
    
    if now > midnight || now < opening
      return 'Clinic closed. Doctors working today: Dr. #{docs}'
    elsif now < closing && now > opening
      return Visit.first.doctor.lname
    else 
      return 'Clinic is closed'
    end
end

end
