class Drug < ApplicationRecord
        
	default_scope -> {order(name: :asc)}

	def format_index 
	   DRUG_FORMATS[self.format.to_sym]
	end
end
