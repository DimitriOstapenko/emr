class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  
# Send new registration notification to staff members
   def new_registration(user)
     @user = user
     emails = User.where('role=?', STAFF_ROLE).pluck(:email) rescue REPLY_TO
     mail to: emails, subject: "User Account Created", from: 'admin@drlena.com'
   end

# Notify doctor about new visit created by patient   
   def new_visit(visit)
     @visit = visit
     email = visit.doctor.email rescue nil
     return unless email 
     mail to: email, subject: "New visit created by patient", from: 'admin@drlena.com'
   end

end
