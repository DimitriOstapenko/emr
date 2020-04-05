class User < ApplicationRecord
# Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :timeoutable , :validatable

  default_scope -> { order(email: :asc) }
  enum role: USER_ROLES

  before_validation :set_patient
  before_validation { self.ohip_num.gsub!(/\D/,'') rescue nil }
  before_validation { self.ohip_ver.strip! rescue nil }
  before_validation { self.email.downcase! rescue '' }

  validates :ohip_num, presence:true, length: { is: 10 }, numericality: { only_integer: true }, uniqueness: true
  validates :ohip_ver, length: { is: 2 }, allow_blank: true

  after_create_commit :send_emails

# Initialize user, set patient
  def set_patient
    self.role ||= :patient
    if self.patient?
      patient = Patient.find_by(ohip_num: self.ohip_num)
      if patient.present?
        self.patient_id = patient.id 
#        patient.update_attribute(:email, self.email) 
      else
        patient = Patient.new(ohip_num: self.ohip_num, ohip_ver: self.ohip_ver, email: self.email)
        patient.save!(validate:false)
        self.patient_id = patient.id 
        self.new_patient = true
      end
#      UserMailer.new_registration(self).deliver
    end
  end

# Override Devise::Confirmable#after_confirmation  
  def after_confirmation
    self.patient.update_attribute(:email, self.email) if self.patient?
  end

  def send_emails
      UserMailer.new_registration(self).deliver
  end  

# name attribute dropped, this is not to break legacy code 
  def name
    self.email
  end

  def patient
    Patient.find(self.patient_id) rescue nil
  end

  def staff?
    self.role == 'staff'
  end

  def admin?
    self.role == 'admin'
  end

   def doctor?
    self.role == 'doctor'
  end

  def patient?
    self.role == 'patient'
  end

private 

def patient_present
  errors.add(:patient_id, "This health card number is not registered in our database. We currently accept clinic patients only") unless self.patient_id 
end

end
