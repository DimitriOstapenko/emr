require 'test_helper'

class ProceduresControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get procedures_new_url
    assert_response :success
  end

  test "should get show" do
    get procedures_show_url
    assert_response :success
  end

  test "should get index" do
    get procedures_index_url
    assert_response :success
  end

  test "should get edit" do
    get procedures_edit_url
    assert_response :success
  end

end
