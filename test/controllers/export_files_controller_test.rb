require 'test_helper'

class ExportFilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get export_files_index_url
    assert_response :success
  end

  test "should get show" do
    get export_files_show_url
    assert_response :success
  end

  test "should get delete" do
    get export_files_delete_url
    assert_response :success
  end

end
