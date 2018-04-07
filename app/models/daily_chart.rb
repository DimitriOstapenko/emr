class DailyChart < ApplicationRecord

	default_scope -> { order(date: :desc) }

        validates :filename, presence: true, length: { maximum: 30 }, uniqueness: true
        validates :date, presence: true, uniqueness: true
        validates :pages, numericality: { only_integer: true }, allow_blank: true

end
