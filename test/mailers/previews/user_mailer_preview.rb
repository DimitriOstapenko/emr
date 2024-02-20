# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.last
    token = user.generate_token
    UserMailer.account_activation(user, token)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
#  def password_reset
#    user = User.first
#    user.reset_token = User.new_token
#    UserMailer.password_reset(user)
#  end

  def notify_admins_about_new_registration
    user = User.last
    UserMailer.new_registration(user)
  end
  
# send email to doctor  
  def send_new_visit_to_doctor
    visit = Visit.find_by(vis_type: 'TV')
    UserMailer.new_visit(visit)
  end

# Invite doctor to register  
  def invite_doctor_to_register
#    doctor = Doctor.where(bills: true).first  # must have user 
    doctor = Doctor.first
    user = doctor.user rescue nil
    UserMailer.invite_doctor( user )
  end

end
