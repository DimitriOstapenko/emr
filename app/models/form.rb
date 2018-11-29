class Form < ApplicationRecord
	
	before_validation { filename.strip! rescue '' }
	attr_accessor :ftype_str, :format_str, :filespec

	mount_uploader :form, FormUploader

	validates :name, presence: true
	validates :form, presence: true
	validates :ftype, presence: true
	validates :descr, presence: true

def ftype_str
	FORM_TYPES.invert[ftype].to_s rescue nil
end

def format_str
	FORM_FORMATS.invert[format].to_s rescue nil
end

def filename
    self.form_identifier
end

def filespec
    self.form.current_path	
end

def fillable_str
	fillable? ? 'Yes' : 'No'
end


end
