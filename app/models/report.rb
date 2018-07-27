class Report < ApplicationRecord

	default_scope -> { order(id: :desc) }
	attr_accessor :doctor, :filespec

	validates :name, presence: true, length: { maximum: 30 }
	validates :rtype, presence: true, numericality: { only_integer: true }
	validates :doc_id, numericality: { only_integer: true }, allow_blank: true
	validates :edate, presence: true, if: Proc.new { |a| a.rtype == 4}
	validates :sdate, presence: true, if: Proc.new { |a| a.rtype == 1 || a.rtype == 4}

  def doctor
	  Doctor.find(doc_id) if doc_id > 0
  end

  def filespec
    REPORTS_PATH.join(filename) rescue nil
  end
  
end
