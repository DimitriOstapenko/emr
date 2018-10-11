module SessionsHelper

# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
    session[:expires_at] = 1.hour.from_now 
    doc = Doctor.find_by(email: user.email) || Doctor.find_by(lname: 'nobody')
    session[:doc_id] = doc.id
  end

# Returns the current logged-in user (if any).
  def current_user
#    @current_user ||= User.find_by(id: session[:user_id])

    if (user_id = session[:user_id])
      @current_user ||= User.find(user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find(user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
	if user.doctor?
	   doc = Doctor.find_by(email: user.email) 
	   set_doc_session( doc.id ) if doc
	end
      end
    end
  end

# Returns true if the user is logged in, false otherwise. Expires regular users
  def logged_in?
    if !session[:expires_at].blank? && current_user.present?
       if current_user.user? && (session[:expires_at] < Time.zone.now)
          log_out 
       else
          session[:expires_at] = 30.minutes.from_now 
       end
    end
    !current_user.nil?
  end  

# Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    session.delete(:doc_id)
    session.delete(:expires_at)
    @current_doctor = nil
    @current_user = nil
  end

# Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
# Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

# Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end
 
# Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

# Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end  

end
