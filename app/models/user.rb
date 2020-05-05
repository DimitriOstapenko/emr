class User < ApplicationRecord
# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :timeoutable , :validatable
  belongs_to :patient

  default_scope -> { order(email: :asc) }
  enum role: USER_ROLES

  before_validation { self.ohip_num.upcase!; self.email.downcase! rescue '' }

  validates :ohip_num, presence:true, length: { maximum: 12 }, numericality: { only_integer: true }, uniqueness: true, if: Proc.new { |u| u.patient? }
  validates :ohip_ver, length: { is: 2 }, allow_blank: true, if: Proc.new { |u| u.patient? }
 
  validates :email, presence: true;

  before_validation :set_patient
  after_create_commit :send_emails

# Initialize user, set patient
  def set_patient
    self.role ||= :patient
    if self.patient?
      self.ohip_num.upcase!;  self.ohip_num.gsub!(/\W/,''); 
      self.ohip_num, self.ohip_ver = self.ohip_num.match(/(\d+)(\S*)/).captures rescue nil
      patient = Patient.find_by(ohip_num: self.ohip_num)
      if patient.present?
        self.patient_id = patient.id 
      else
        patient = Patient.new(ohip_num: self.ohip_num, ohip_ver: self.ohip_ver, email: self.email, dob: self.dob)
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

  def patient
    Patient.find(self.patient_id) rescue nil
  end
  
  def doctor
    Doctor.find(self.doctor_id) rescue nil
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

# Global method; search by email (has to have @), patient last name, patient full name with comma after last 
  def self.search(keyword = '')
     case keyword
     when /\w+@/                                                       # full/partial email
       users = User.where("email like ?", "%#{keyword}%")
     when /^[[:graph:]]+/                                             # last name[, fname]
       lname,fname = keyword.tr(' ','').split(',')
       if fname.blank?        # Search by last name or maiden name if no first name given
          users = User.joins(:patient).where("upper(lname) like ? OR upper(maid_name) like ?", "#{lname.upcase}%", "%#{lname.upcase}")
       else
          users = User.joins(:patient).where("upper(lname) like ? AND upper(fname) like ?", "#{lname.upcase}%", "%#{fname.upcase}%")
       end
     else
       users = []
     end
    return users.order(:email)
  end

private 

end
