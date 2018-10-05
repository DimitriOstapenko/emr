class EdtFile < ApplicationRecord
	default_scope -> {order(id: :desc)}

        attr_accessor :filespec

        validates :ftype, presence: true, inclusion: { in: 0..5 }
        validates :filename, length: { maximum: 100 }, presence: true, uniqueness: true
	validates :lines, numericality: { only_integer: true, only_positive: true }
        validates :seq_no, presence: true, inclusion: { in: 0..999 }

# Construct full filespec	
def filespec
    EDT_PATH.join(filename) rescue nil
end

# Write EDT claim to file
def write
      begin
      file = File.open(self.filespec, 'w')
      file.write( self.body )
      rescue Errno::ENOENT => e
	errors.add('Error:', e.message.inspect)
      ensure
        file.close
      end
end

def ftype_str
    EDT_FILE_TYPES.invert[ftype].to_s
end

end
