class Form < ApplicationRecord

	attr_accessor :ftype_str, :format_str, :filespec

def ftype_str
	FORM_TYPES.invert[ftype].to_s rescue nil
end

def format_str
	FORM_FORMATS.invert[format].to_s rescue nil
end

def filespec
	FORMS_PATH.join(filename) rescue nil
end

def fillable_str
	fillable? ? 'Yes' : 'No'
end


end
