class ApplicationMailer < ActionMailer::Base
  default from: REPLY_TO
  layout 'mailer'
end
