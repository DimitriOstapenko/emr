require "application_system_test_case"

class ReferralsTest < ApplicationSystemTestCase
  setup do
    @referral = referrals(:one)
  end

  test "visiting the index" do
    visit referrals_url
    assert_selector "h1", text: "Referrals"
  end

  test "creating a Referral" do
    visit referrals_url
    click_on "New Referral"

    fill_in "Address To", with: @referral.address_to
    fill_in "App Date", with: @referral.app_date
    fill_in "Date", with: @referral.date
    fill_in "Doctor", with: @referral.doctor_id
    fill_in "Filename", with: @referral.filename
    fill_in "From", with: @referral.from
    fill_in "Patient", with: @referral.patient_id
    fill_in "Reason", with: @referral.reason
    fill_in "To", with: @referral.to
    fill_in "Visit", with: @referral.visit_id
    click_on "Create Referral"

    assert_text "Referral was successfully created"
    click_on "Back"
  end

  test "updating a Referral" do
    visit referrals_url
    click_on "Edit", match: :first

    fill_in "Address To", with: @referral.address_to
    fill_in "App Date", with: @referral.app_date
    fill_in "Date", with: @referral.date
    fill_in "Doctor", with: @referral.doctor_id
    fill_in "Filename", with: @referral.filename
    fill_in "From", with: @referral.from
    fill_in "Patient", with: @referral.patient_id
    fill_in "Reason", with: @referral.reason
    fill_in "To", with: @referral.to
    fill_in "Visit", with: @referral.visit_id
    click_on "Update Referral"

    assert_text "Referral was successfully updated"
    click_on "Back"
  end

  test "destroying a Referral" do
    visit referrals_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Referral was successfully destroyed"
  end
end
