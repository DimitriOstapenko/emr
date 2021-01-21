class SystemMailer < ApplicationMailer

  # Send alert to concerned parties about HCV service being down
   def hcv_alert
     emails = User.where('role=?', ADMIN_ROLE).pluck(:email) rescue REPLY_TO
     mail to: emails, subject: "HCV service is down!", from: 'admin@drlena.com'
   end

end
