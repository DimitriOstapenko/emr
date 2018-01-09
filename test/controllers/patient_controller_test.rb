require 'test_helper'

class PatientsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @pat       = patients(:one)
    @other_pat = patients(:two)
  end

  test "should redirect index when not logged in" do
    get patients_path
    assert_redirected_to login_url
  end

  test "should get new patient" do
    get patsignup_path
    assert_response :success
  end
  
  test "should redirect update when not logged in" do
    patch patient_path(@pat), params: { patient: { lname: @pat.lname, fname: @pat.fname, dob: @pat.dob, ohip_num: @pat.ohip_num, sex: @pat.sex, phone: @pat.phone }}
    assert_not flash.empty?
    assert_redirected_to login_url
  end
end
