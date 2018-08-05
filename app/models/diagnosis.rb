class Diagnosis < ApplicationRecord

	default_scope -> { order(descr: :asc) }

	validates :code, presence: true, length: { maximum: 7 }, uniqueness: true,  numericality: true
	validates :descr, presence: true, length: { maximum: 100 }
	validates :prob_type, length: {maximum: 80}, allow_blank: true

def code_with_descr
  "#{code} : #{descr}"
end

def descr_with_code
  "#{descr}  (#{code})"
end

end
