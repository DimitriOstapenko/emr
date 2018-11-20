class DailyChart < ApplicationRecord

	default_scope -> { order(date: :desc) }

        validates :filename, presence: true, length: { maximum: 30 }, uniqueness: true
        validates :date, presence: true, uniqueness: true
        validates :pages, numericality: { only_integer: true }, allow_blank: true


def filespec
  (year,mon,rest) = self.filename.split('-') 
  CHARTS_PATH.join('Daily',year,self.filename) rescue nil
end

def rel_path
  (year,mon,rest) = filename.split('-') 
  "Daily/#{year}/#{filename}"
end

def filesize 
  sprintf("%.2f", File.size(self.filespec).to_f/2**20) rescue 0
end

end
