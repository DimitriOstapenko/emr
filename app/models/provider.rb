class Provider < ApplicationRecord
        default_scope -> {order(name: :asc)}

	before_validation { name.upcase! rescue '' }
	before_validation { name.strip! rescue '' }
	before_validation { postal.upcase! rescue '' }
	before_validation { prov.upcase! rescue '' }
	before_validation { city.upcase! rescue '' }
	before_validation { country.upcase! rescue '' }
	before_validation { phone1.gsub!(/\D/,'') rescue ''}
	before_validation { phone2.gsub!(/\D/,'') rescue ''}
	before_validation { fax.gsub!(/\D/,'') rescue ''}
	before_validation { postal.gsub!(/\s/,'') rescue '' }

#!	validates :prov,  length: { is: 2 }
#!	validates :postal, length: { is: 6 }, allow_blank: true
	
end
