class Report < ApplicationRecord

	default_scope -> { order(id: :desc) }
	attr_accessor :doctor, :filespec

	validates :name, presence: true, length: { maximum: 30 }
	validates :rtype, presence: true, inclusion: { in: [SC_REPORT, PC_REPORT] } 
	validates :timeframe, numericality: { only_integer: true }, allow_blank: true
	validates :doc_id, numericality: { only_integer: true }, allow_blank: true
	validates :sdate, presence: true, if: Proc.new { |a| a.rtype == DAILY_REPORT || a.rtype == DRANGE_REPORT}
	validates :edate, presence: true, if: Proc.new { |a| a.rtype == DRANGE_REPORT}

  def doctor
	  Doctor.find(doc_id) if doc_id > 0
  end

  def filespec
    REPORTS_PATH.join(filename) rescue nil
  end
  
end
