require 'test_helper'

class ChartsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get charts_index_url
    assert_response :success
  end

  test "should get new" do
    get charts_new_url
    assert_response :success
  end

  test "should get create" do
    get charts_create_url
    assert_response :success
  end

  test "should get show" do
    get charts_show_url
    assert_response :success
  end

  test "should get edit" do
    get charts_edit_url
    assert_response :success
  end

  test "should get update" do
    get charts_update_url
    assert_response :success
  end

  test "should get delete" do
    get charts_delete_url
    assert_response :success
  end

  test "should get download" do
    get charts_download_url
    assert_response :success
  end

end
