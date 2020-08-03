class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  
# Send new registration notification to admin members
   def new_registration(user)
     @user = user
     emails = User.where('role=?', ADMIN_ROLE).pluck(:email) rescue REPLY_TO
     mail to: emails, subject: "User Account Created", from: 'admin@drlena.com'
   end

# Notify doctor about new visit created by patient   
   def new_visit(visit)
     @visit = visit
     email = visit.doctor.email rescue nil
     return unless email 
     mail to: email, subject: "New visit created by patient", from: 'admin@drlena.com'
   end

# Invite doctor to confirm their email and change password; Pass user object with doctor_id set 
   def invite_doctor( user )
     @user = user
     @doctor = user.doctor
     return unless @user && @doctor

     @raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
     @user.reset_password_sent_at = @user.confirmed_at = Time.now.utc
     @user.reset_password_token = hashed
     @user.save

     mail to: @doctor.email, subject: "Invitation to register to Walk-In EMR"

   end

end
