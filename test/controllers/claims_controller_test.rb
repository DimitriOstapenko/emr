require 'test_helper'

class ClaimsControllerTest < ActionDispatch::IntegrationTest
#class ClaimsControllerTest < ActionController::TestCase

 def setup
    @claim       = claims(:one)
    @other_claim = claims(:two)
    @user        = users(:michael)
#    sign_in_as @user
  end

  test "should redirect index when not logged in" do
    get claims_url
    assert_redirected_to login_url
  end

  test "should get index" do

#     get :new, session: {user_id: 1}
#    puts @user.inspect
#	  request.session[:user_id] = @user.id
    sign_in_as(@user)
	  get claims_url #, params: { session: { user_id: @user.id } }
#    assert_redirected_to login_url, 'Did not redirect'
    assert_response :success
  end

#  test "should get show" do
#    get claims_show_url
#    assert_response :success
#  end

end
