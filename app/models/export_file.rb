class ExportFile < ApplicationRecord
	default_scope -> { order(sdate: :desc) }

        validates :name, presence: true, length: { is: 12 }
        validates :sdate, presence: true
	validates :ttl_claims, presence: true, numericality: { only_integer: true }
	

end
