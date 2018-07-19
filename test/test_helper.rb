ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase 
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper
  include SessionsHelper

  def is_logged_in?
    !session[:user_id].nil?
  end

  # Log in as a particular user.
  def log_in_as(user)
    puts "in log_in_user : #{user.id}"	  
    controller.session[:user_id] = user.id
  end
  
  def sign_in_as(user, pass: 'musia4391')
	 # post login_path, params: { session: {user_id: user.id }}
	  post login_path, params: { session: { email: 'tt@t.com', password: 'musia4391'} }
	  puts 'curuser:', current_user.inspect
  end

end
