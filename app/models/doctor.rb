class Doctor < ApplicationRecord
        attr_accessor :full_name, :age
        default_scope -> {order(lname: :asc)}
        validates :lname, presence: true, length: { maximum: 50 }
        validates :fname, presence: true, length: { maximum: 50 }
	validates :service, presence: true, length: { is: 4}
	validates :ph_type, presence: true, length: { is: 2}
        validates :licence_no, numericality: { only_integer: true }, uniqueness: { case_sensitive: false }
        validates :bills, inclusion: { in: [true, false] }
        validates :phone, presence: true # , length: { is: 10 }, numericality: { only_integer: true }
        validates :billing_num, numericality: { only_integer: true }, uniqueness: { case_sensitive: false } 
	validates :cpso_num, numericality: { only_integer: true }, uniqueness: { case_sensitive: false }, length: { is: 5 } 
	validates :provider_no, numericality: { only_integer: true }, uniqueness: { case_sensitive: false }, presence: true, length: { is: 6 }  
	validates :group_no, numericality: { only_integer: true }, length: {is: 4}  
	validates :specialty, numericality: { only_integer: true }, length: {is: 2}, presence: true  

  def full_name
    [fname, lname].join(', ')
  end


end
