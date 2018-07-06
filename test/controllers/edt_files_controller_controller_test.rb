require 'test_helper'

class EdtFilesControllerControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get edt_files_controller_new_url
    assert_response :success
  end

  test "should get show" do
    get edt_files_controller_show_url
    assert_response :success
  end

  test "should get update" do
    get edt_files_controller_update_url
    assert_response :success
  end

  test "should get destroy" do
    get edt_files_controller_destroy_url
    assert_response :success
  end

end
