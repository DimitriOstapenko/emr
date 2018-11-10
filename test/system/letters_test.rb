require "application_system_test_case"

class LettersTest < ApplicationSystemTestCase
  setup do
    @letter = letters(:one)
  end

  test "visiting the index" do
    visit letters_url
    assert_selector "h1", text: "Letters"
  end

  test "creating a Letter" do
    visit letters_url
    click_on "New Letter"

    fill_in "Address To", with: @letter.address_to
    fill_in "Body", with: @letter.body
    fill_in "Date", with: @letter.date
    fill_in "Doctor", with: @letter.doctor_id
    fill_in "Filename", with: @letter.filename
    fill_in "Note", with: @letter.note
    fill_in "Patient", with: @letter.patient_id
    fill_in "Title", with: @letter.title
    fill_in "To", with: @letter.to
    fill_in "Visit", with: @letter.visit_id
    click_on "Create Letter"

    assert_text "Letter was successfully created"
    click_on "Back"
  end

  test "updating a Letter" do
    visit letters_url
    click_on "Edit", match: :first

    fill_in "Address To", with: @letter.address_to
    fill_in "Body", with: @letter.body
    fill_in "Date", with: @letter.date
    fill_in "Doctor", with: @letter.doctor_id
    fill_in "Filename", with: @letter.filename
    fill_in "Note", with: @letter.note
    fill_in "Patient", with: @letter.patient_id
    fill_in "Title", with: @letter.title
    fill_in "To", with: @letter.to
    fill_in "Visit", with: @letter.visit_id
    click_on "Update Letter"

    assert_text "Letter was successfully updated"
    click_on "Back"
  end

  test "destroying a Letter" do
    visit letters_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Letter was successfully destroyed"
  end
end
