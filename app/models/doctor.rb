class Doctor < ApplicationRecord
        attr_accessor :full_name, :age
        default_scope -> {order(lname: :asc)}
        validates :lname, presence: true, length: { maximum: 50 }
        validates :fname, length: { maximum: 50 }
	validates :service, presence: true, length: { is: 4}
	validates :ph_type, presence: true, length: { is: 2}
#        validates :licence_no #, numericality: { only_integer: true }
#        validates :billing_num , numericality: { only_integer: true }
#	validates :cpso_num, numericality: { only_integer: true }, uniqueness: true, length: { is: 5 } 
        validates :bills, inclusion: { in: [true, false] }
        validates :phone, length: { maximum: 15 }  #, numericality: { only_integer: true }
        validates :mobile, length: {maximum: 15}
	validates :provider_no, numericality: { only_integer: true }, length: { is: 6 }  
#	validates :group_no, numericality: { only_integer: true }, length: {is: 4}  
	validates :specialty, numericality: { only_integer: true }, length: {is: 2} 
        validates :district, length: { is: 1 }
	validates :address, length: {maximum: 100}
	validates :city, length: {maximum: 30}
	validates :prov, length: { is: 2 }
	validates :postal, length: { maximum: 10 }
        validates :note, length: {maximum: 255}
        validates :office, length: {maximum: 15}
        validates :email, length: {maximum: 30}

  def full_name
    [fname, lname].join(', ')
  end


end

