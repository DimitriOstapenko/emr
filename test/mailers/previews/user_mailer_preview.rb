# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
#  def account_activation
#    user = User.first
#    user.activation_token = User.new_token
#    UserMailer.account_activation(user)
#  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
#  def password_reset
#    user = User.first
#    user.reset_token = User.new_token
#    UserMailer.password_reset(user)
#  end

  def new_registration
    user = User.last
    UserMailer.new_registration(user)
  end
  
# send email to doctor  
  def new_visit
    visit = Visit.find_by(vis_type: 'TV')
    UserMailer.new_visit(visit)
  end

# Invite doctor to register  
  def invite_doctor
    doctor = Doctor.where(bills: true).first  # must have user 
    user = doctor.user rescue nil
    UserMailer.invite_doctor( user )
  end

end
