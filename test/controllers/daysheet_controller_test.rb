require 'test_helper'

class DaysheetControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get daysheet_index_url
    assert_response :success
  end

end
