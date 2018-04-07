require 'test_helper'

class DailyChartsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get daily_charts_new_url
    assert_response :success
  end

  test "should get create" do
    get daily_charts_create_url
    assert_response :success
  end

  test "should get show" do
    get daily_charts_show_url
    assert_response :success
  end

  test "should get index" do
    get daily_charts_index_url
    assert_response :success
  end

  test "should get edit" do
    get daily_charts_edit_url
    assert_response :success
  end

  test "should get update" do
    get daily_charts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get daily_charts_destroy_url
    assert_response :success
  end

end
