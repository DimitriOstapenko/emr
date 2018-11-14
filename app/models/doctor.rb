class Doctor < ApplicationRecord
        has_many :visits
	has_many :patients, through: :visits

        attr_accessor :full_name, :age
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

        default_scope -> {order( bills: :desc, lname: :asc)}
	
	before_validation { phone.gsub!(/\D/,'') rescue '' }
	before_validation { mobile.gsub!(/\D/,'') rescue '' }
	before_validation { district.gsub!(/\D/,'') rescue 0 }
	before_validation { provider_no.gsub!(/\D/,'') rescue '' }
	before_validation { group_no.gsub!(/\D/,'') rescue ''  }
	before_validation { cpso_num.gsub!(/\D/,'') rescue 0 }
	before_validation { wsib_num.gsub!(/\D/,'') rescue 0 }

        validates :lname, presence: true, length: { maximum: 50 }
        validates :fname, length: { maximum: 50 }, allow_blank: true
        validates :specialty,  presence: true, numericality: { only_integer: true }, length: { is: 2 }
        validates :wsib_num, numericality: { only_integer: true }
	validates :cpso_num, numericality: { only_integer: true }, length: { maximum: 6 }, allow_blank: true
	validates :provider_no, presence: true, numericality: { only_integer: true }, length: { is: 6 }, allow_blank: true 
	validates :group_no, numericality: { only_integer: true }, length: {is: 4}, allow_blank: true
        validates :phone, length: { maximum: 15 }  #, numericality: { only_integer: true }
        validates :mobile, length: {maximum: 15}, allow_blank: true
        validates :district, numericality: { only_integer: true }
	validates :city, length: {maximum: 30}, allow_blank: true
	validates :prov, length: { is: 2 }, allow_blank: true
	validates :postal, length: { maximum: 10 }, allow_blank: true
        validates :note, length: {maximum: 255}, allow_blank: true
        validates :office, length: {maximum: 255}, allow_blank: true
        validates :email, length: { maximum: 80 }, allow_blank: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :percent_deduction, presence: true, :numericality => { :greater_than_or_equal_to => 0 }, if: Proc.new { |d| (d.bills == true)}
	validates :bills, inclusion: { in: [true, false] }

	validate :provider_no_required_if_bills


  def full_name
    return fname.blank? ? lname : [lname, fname].join(', ')
  end

# Is doctor set to default doctor?
  def fake?
    lname == 'nobody'
  end

  def bills_str
    self.bills? ? 'Yes' : 'No' 
  end
  
  def accepts_str
    self.accepts_new_patients? ? 'Yes' : 'No' 
  end

private 
  def provider_no_required_if_bills
    errors.add(:provider_no, "is required for billing doctors") if 
      bills? and provider_no.blank?
  end
end
