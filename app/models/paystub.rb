class Paystub < ApplicationRecord

	default_scope -> { order(year: :desc, month: :desc) }
        attr_accessor :doctor

        validates :doc_id, numericality: { only_integer: true }, presence: true
        validates :year, presence: true, numericality: { only_integer: true }
        validates :month, presence: true, numericality: { only_integer: true }

  def doctor
          Doctor.find(doc_id) if doc_id > 0
  end

  def non_ohip_amt
	  net_amt - ohip_amt rescue 0
  end

end
