require 'test_helper'

class DoctorsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @doc       = doctors(:one)
    @other_doc = doctors(:two)
  end

  test "should redirect index when not logged in" do
    get doctors_path
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch doctor_path(@doc), params: { doctor: { lname: @doc.lname, 
						 fname: @doc.fname,
						 provider_no: @doc.provider_no,
						 group_no: @doc.group_no,
						 specialty: @doc.specialty,
						 phone: @doc.phone }}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

#  test "should get new" do
#    get doctors_new_url
#    assert_response :success
#  end

#  test "should get show" do
#    get doctors_show_url
#    assert_response :success
#  end

#  test "should get index" do
#    get doctors_index_url
#    assert_response :success
#  end

end
