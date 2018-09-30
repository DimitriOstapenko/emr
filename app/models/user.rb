class User < ApplicationRecord
  enum role: USER_ROLES 
  after_initialize :set_default_role, :if => :new_record?

  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

# Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

# Get URL safe secure token  
  def User.new_token
    SecureRandom.urlsafe_base64
  end

# Save token to DB for persistent sessions  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

# Forget a user - clear persistent session
  def forget
    update_attribute(:remember_digest, nil)
  end

# Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def set_default_role
    self.role ||= :user
  end

  def admin?
    self.role == 'admin'
  end
  
  def doctor?
    self.role == 'doctor'
  end

private
# Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

# Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
