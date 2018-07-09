require 'test_helper'

class PaystubsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get paystubs_new_url
    assert_response :success
  end

  test "should get create" do
    get paystubs_create_url
    assert_response :success
  end

  test "should get update" do
    get paystubs_update_url
    assert_response :success
  end

  test "should get edit" do
    get paystubs_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get paystubs_destroy_url
    assert_response :success
  end

  test "should get index" do
    get paystubs_index_url
    assert_response :success
  end

  test "should get show" do
    get paystubs_show_url
    assert_response :success
  end

end
