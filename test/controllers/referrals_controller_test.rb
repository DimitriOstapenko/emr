require 'test_helper'

class ReferralsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @referral = referrals(:one)
  end

  test "should get index" do
    get referrals_url
    assert_response :success
  end

  test "should get new" do
    get new_referral_url
    assert_response :success
  end

  test "should create referral" do
    assert_difference('Referral.count') do
      post referrals_url, params: { referral: { address_to: @referral.address_to, app_date: @referral.app_date, date: @referral.date, doctor_id: @referral.doctor_id, filename: @referral.filename, from: @referral.from, patient_id: @referral.patient_id, reason: @referral.reason, to: @referral.to, visit_id: @referral.visit_id } }
    end

    assert_redirected_to referral_url(Referral.last)
  end

  test "should show referral" do
    get referral_url(@referral)
    assert_response :success
  end

  test "should get edit" do
    get edit_referral_url(@referral)
    assert_response :success
  end

  test "should update referral" do
    patch referral_url(@referral), params: { referral: { address_to: @referral.address_to, app_date: @referral.app_date, date: @referral.date, doctor_id: @referral.doctor_id, filename: @referral.filename, from: @referral.from, patient_id: @referral.patient_id, reason: @referral.reason, to: @referral.to, visit_id: @referral.visit_id } }
    assert_redirected_to referral_url(@referral)
  end

  test "should destroy referral" do
    assert_difference('Referral.count', -1) do
      delete referral_url(@referral)
    end

    assert_redirected_to referrals_url
  end
end
