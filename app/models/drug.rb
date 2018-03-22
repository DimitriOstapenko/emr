class Drug < ApplicationRecord
        
	default_scope -> {order(name: :asc)}
end
