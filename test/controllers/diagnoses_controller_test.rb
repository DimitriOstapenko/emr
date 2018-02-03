require 'test_helper'

class DiagnosesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @diag       = diagnoses(:one)
    @other_diag = diagnoses(:two)
  end

  test "should redirect index when not logged in" do
    get diagnoses_path
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
	  patch diagnosis_path(@diag), params: { diagnosis: { code: @diag.code, descr: @diag.descr, prob_type: @diag.prob_type }}
    
    assert_not flash.empty?
    assert_redirected_to login_url
  end


#  test "should get new" do
#    get diagnoses_new_url
#    assert_response :success
#  end

#  test "should get show" do
#    get diagnoses_show_url
#    assert_response :success
#  end

#  test "should get index" do
#    get diagnoses_index_url
#    assert_response :success
#  end

#  test "should get edit" do
#    get diagnoses_edit_url
#    assert_response :success
#  end

end
