require 'test_helper'

#
# Session doesnt work with ActionDispatch::IntegrationTest
#
class UsersEditTest <  ActionDispatch::IntegrationTest #ActionController::TestCase   #ActionDispatch::IntegrationTest

 def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

#  test "my - check session" do
#	  get edit_user_path(@user)
#          assert_template 'users/edit'
#	  log_in_as (@user)
#	  assert_equal session[:user_id], @user.id
#  end


#  test "unsuccessful edit" do
#    log_in_as(@user)
#    get edit_user_path(@user)
#    assert_template 'users/edit'
#    patch user_path(@user), params: { user: { name:  "",
#                                              email: "foo@invalid",
#                                              password:              "foo",
#                                              password_confirmation: "bar" } }
#
#    assert_template 'users/edit'
#  end
  
#  test "successful edit" do
#    log_in_as(@user)
#    get edit_user_path(@user)
#    assert_template 'users/edit'
#    name  = "Foo Bar"
#    email = "foo@bar.com"
#    patch user_path(@user), params: { user: { name:  name,
#                                              email: email,
#                                              password:              "",
#                                              password_confirmation: "" } }
#    assert_not flash.empty?
#    assert_redirected_to @user
#    @user.reload
#    assert_equal name,  @user.name
#    assert_equal email, @user.email
#  end

 test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
 
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

#  test "should redirect edit when logged in as wrong user" do
#    log_in_as(@other_user)
#    get edit_user_path(@user)
#    assert flash.empty?
#    assert_redirected_to root_url
#  end

#  test "should redirect update when logged in as wrong user" do
#    log_in_as(@other_user)
#    patch user_path(@user), params: { user: { name: @user.name,
#                                              email: @user.email } }
#    assert flash.empty?
#    assert_redirected_to root_url
#  end


end
