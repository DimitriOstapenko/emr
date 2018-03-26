require 'test_helper'

class VaccinesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get vaccines_new_url
    assert_response :success
  end

  test "should get create" do
    get vaccines_create_url
    assert_response :success
  end

  test "should get index" do
    get vaccines_index_url
    assert_response :success
  end

  test "should get show" do
    get vaccines_show_url
    assert_response :success
  end

  test "should get edit" do
    get vaccines_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get vaccines_destroy_url
    assert_response :success
  end

end
