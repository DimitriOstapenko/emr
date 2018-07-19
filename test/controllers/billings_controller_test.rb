require 'test_helper'

class BillingsControllerTest < ActionDispatch::IntegrationTest
  
#  def setup
#    @user       = users(:michael)
#  end

  test "should get index page" do
    get billings_path
    assert_redirected_to login_url
  end
  
#  test "should get new" do
#    get signup_path
#    assert_response :success
#  end

end
