class Form < ApplicationRecord
	
	before_validation { filename.strip! rescue '' }
	attr_accessor :ftype_str, :format_str, :filespec

	mount_uploader :form, FormUploader

	validates :name, presence: true
#	validates :filename, presence: true
	validates :ftype, presence: true

def ftype_str
	FORM_TYPES.invert[ftype].to_s rescue nil
end

def format_str
	FORM_FORMATS.invert[format].to_s rescue nil
end

def filespec
    self.form.current_path	
end

def fillable_str
	fillable? ? 'Yes' : 'No'
end


end
