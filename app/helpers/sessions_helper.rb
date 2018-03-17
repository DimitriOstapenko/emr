module SessionsHelper

# Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
    session[:expires_at] = Time.now.midnight + 1.day
  end

# Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

# Returns true if the user is logged in, false otherwise.
  def logged_in?
    if !session[:expires_at].blank? 
       log_out if session[:expires_at] < Time.now
    end
    !current_user.nil?
  end  

# Logs out the current user.
  def log_out
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
