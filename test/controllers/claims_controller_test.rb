require 'test_helper'

class ClaimsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get claims_index_url
    assert_response :success
  end

  test "should get show" do
    get claims_show_url
    assert_response :success
  end

end
