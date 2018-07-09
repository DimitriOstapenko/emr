require 'test_helper'

class EdtFilesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get edt_files_new_url
    assert_response :success
  end

  test "should get create" do
    get edt_files_create_url
    assert_response :success
  end

  test "should get destroy" do
    get edt_files_destroy_url
    assert_response :success
  end

  test "should get index" do
    get edt_files_index_url
    assert_response :success
  end

  test "should get show" do
    get edt_files_show_url
    assert_response :success
  end

end
