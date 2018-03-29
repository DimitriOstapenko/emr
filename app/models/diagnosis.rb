class Diagnosis < ApplicationRecord

	attr_accessor :scode
	default_scope -> { order(code: :asc) }

	validates :code, presence: true, length: { maximum: 10 }, uniqueness: true,  numericality: true
#!	validates :descr, presence: true, length: { maximum: 100 }
	validates :prob_type, length: {maximum: 80}, allow_blank: true

	def scode 
            code[0,3]
	end

	def code_with_descr
		"#{code} : #{descr}"
	end
end
