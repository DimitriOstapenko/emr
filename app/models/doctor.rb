class Doctor < ApplicationRecord
        has_many :visits
	has_many :patients, through: :visits

        attr_accessor :full_name, :age
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

        default_scope -> {order( bills: :desc, lname: :asc)}

        validates :lname, presence: true, length: { maximum: 50 }
        validates :fname, length: { maximum: 50 }, allow_blank: true
	validates :service, presence: true, length: { is: 4}
	validates :ph_type, presence: true, length: { is: 2}
#        validates :licence_no #, numericality: { only_integer: true }, allow_blank: true
        validates :billing_num , numericality: { only_integer: true }
	validates :cpso_num, numericality: { only_integer: true }, length: { is: 5 }, allow_blank: true
	validates :bills, inclusion: { in: [true, false] }
        validates :phone, length: { maximum: 15 }  #, numericality: { only_integer: true }
        validates :mobile, length: {maximum: 15}, allow_blank: true
	validates :provider_no, numericality: { only_integer: true }, length: { is: 6 }, allow_blank: true 
	validates :group_no, numericality: { only_integer: true }, length: {is: 4}, allow_blank: true
	validates :specialty, numericality: { only_integer: true }, length: {is: 2}, allow_blank: true 
        validates :district, length: { is: 1 }
	validates :address, length: {maximum: 100}, allow_blank: true
	validates :city, length: {maximum: 30}, allow_blank: true
	validates :prov, length: { is: 2 }, allow_blank: true
	validates :postal, length: { maximum: 10 }, allow_blank: true
        validates :note, length: {maximum: 255}, allow_blank: true
        validates :office, length: {maximum: 255}, allow_blank: true
        validates :email, length: { maximum: 255 }, allow_blank: true   #format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }, allow_blank: true
	validates :percent_deduction, presence: true, :numericality => { :greater_than_or_equal_to => 0 }, if: Proc.new { |d| (d.bills == true)}

	validate :provider_no_required_if_bills

  def full_name
    return fname.blank? ? lname : [lname, fname].join(', ')
  end

  def provider_no_required_if_bills
    errors.add(:provider_no, "is required for billing doctors") if 
      bills? and provider_no.blank?
  end

# Is doctor set to default doctor?
  def fake?
    lname == 'nobody'
  end

  def bills_str
    self.bills? ? 'Yes' : 'No' 
  end

end
