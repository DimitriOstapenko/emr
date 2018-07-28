require 'test_helper'

class RaMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ra_messages_index_url
    assert_response :success
  end

  test "should get show" do
    get ra_messages_show_url
    assert_response :success
  end

end
