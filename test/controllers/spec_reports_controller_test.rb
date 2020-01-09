require 'test_helper'

class SpecReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get spec_reports_index_url
    assert_response :success
  end

  test "should get new" do
    get spec_reports_new_url
    assert_response :success
  end

  test "should get create" do
    get spec_reports_create_url
    assert_response :success
  end

end
