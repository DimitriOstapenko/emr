class Drug < ApplicationRecord
        
	default_scope -> {order(name: :asc)}
	validates :name, presence: true 
	validates :strength, presence: true 
	validates :format, presence: true 
	validates :route, presence: true 
	validates :dose, presence: true 
	validates :freq, presence: true 

	def format_index 
	   DRUG_FORMATS[self.format.to_sym]
	end
end
