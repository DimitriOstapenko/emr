class User < ApplicationRecord
# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :timeoutable , :validatable

  default_scope -> { order(email: :asc) }
  enum role: USER_ROLES

  belongs_to :doctor
  belongs_to :patient

  before_validation { self.ohip_num.upcase!; 
                      self.ohip_num.gsub!(/\W/,'');
                      self.ohip_num, ver = self.ohip_num.match(/(\d+)(\S*)/).captures rescue nil;
                      self.ohip_ver ||= ver
                      self.email.downcase! rescue '' }

  validates :ohip_num, presence:true, length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true, if: Proc.new { |u| u.patient? }
  validates :ohip_ver, length: { is: 2 }, allow_blank: true, if: Proc.new { |u| u.patient? }
 
  validates :email, presence: true;

  after_validation :set_patient
  after_create_commit :send_emails

# Initialize user, set patient
  def set_patient
    self.role ||= :patient
    if self.patient?
      patient = Patient.find_by(ohip_num: self.ohip_num)
      if patient.present?
        self.patient_id = patient.id 
      else
        patient = Patient.new(ohip_num: self.ohip_num, ohip_ver: self.ohip_ver, email: self.email)
        patient.save!(validate:false)
        self.patient_id = patient.id 
        self.new_patient = true
      end
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

#  def patient
#    Patient.find(self.patient_id) rescue nil
#  end

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

end
