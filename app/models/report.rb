class Report < ApplicationRecord

	default_scope -> { order(name: :desc) }
	attr_accessor :doctor

	validates :name, presence: true, length: { maximum: 30 }
	validates :rtype, presence: true, numericality: { only_integer: true }
	validates :doc_id, presence: true, numericality: { only_integer: true }
	validates :filespec, presence: true, length: { maximum: 80 }
	validates :edate, presence: true, if: Proc.new { |a| a.rtype == 4}
	validates :sdate, presence: true, if: Proc.new { |a| a.rtype == 1 || a.rtype == 4}

  def doctor
	  Doctor.find(doc_id) if doc_id > 0
  end
  
end
