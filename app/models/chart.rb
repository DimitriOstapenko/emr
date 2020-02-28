class Chart < ApplicationRecord
	belongs_to :patient
#        default_scope -> { includes(:patient).order(pages: :asc) }
        default_scope -> { order(filename: :asc) }

        validates :pages, numericality: { only_integer: true }, allow_blank: true
        validates :patient_id, presence: true, numericality: { only_integer: true } 

        mount_uploader :chart, ChartUploader
  
        before_save :set_attrs
        after_save  :join_files

def doctor
  Doctor.find(self.doctor_id) rescue nil
end	

def filespec
  CHARTS_PATH.join(self.chart_identifier) rescue nil
# CHARTS_PATH.join(self.chart) rescue nil  # use this instead when running utils/rename_charts.rb script 
end

def filesize
  sprintf("%.2f", File.size(self.filespec).to_f/2**20) rescue 0
end

def exists?
  File.exists?(self.filespec) rescue false
end

# Rename file before appending to it
def rename
  File.rename(self.filespec, "#{self.filespec}_") if self.exists?
end

private

def set_attrs       
  self.pages = PDF::Reader.new( self.filespec ).page_count rescue 0
  self.filename = self.patient.chart_filename
end

def join_files
  backup_chart = "#{self.filespec}_"
  if File.exists?(backup_chart)
#     (CombinePDF.load(backup_chart) << CombinePDF.load(self.filespec)).save(self.filespec)
     (CombinePDF.load(self.filespec) << CombinePDF.load(backup_chart)).save(self.filespec)
     File.rename(backup_chart, File.join(File.dirname(backup_chart), File.basename(backup_chart,'.pdf_') + '.bak')) # prevent second combine
  end 
end

end
