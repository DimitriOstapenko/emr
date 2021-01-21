class SvcMonitor < ApplicationRecord

  validates :name, presence: true, uniqueness: true
  validates :up, presence: true, inclusion: [true, false]


  def send_hcv_alert
    SystemMailer.hcv_alert.deliver
  end

end
