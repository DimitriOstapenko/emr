module SessionsHelper

  def logged_in?
    current_user.present?
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
