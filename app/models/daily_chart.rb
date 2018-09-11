class DailyChart < ApplicationRecord

	default_scope -> { order(date: :desc) }

        validates :filename, presence: true, length: { maximum: 30 }, uniqueness: true
        validates :date, presence: true, uniqueness: true
        validates :pages, numericality: { only_integer: true }, allow_blank: true


def filespec
  (year,mon,rest) = filename.split('-') 
  Rails.root.join(CHARTS_PATH,"Daily/#{year}",filename) rescue nil
end

def rel_path
  (year,mon,rest) = filename.split('-') 
  "Daily/#{year}/#{filename}"
end

end
