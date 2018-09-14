class EdtFile < ApplicationRecord
	default_scope -> {order(id: :desc)}

        attr_accessor :filespec

        validates :ftype, presence: true, inclusion: { in: 0..5 }
        validates :filename, length: { maximum: 100 }, presence: true
	validates :lines, numericality: { only_integer: true, only_positive: true }
        validates :seq_no, presence: true, inclusion: { in: 0..31 }

def filespec
    EDT_PATH.join(filename) rescue nil
end


end
