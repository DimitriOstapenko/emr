require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  def setup
    @pat = Patient.new(lname: "Last", 
		       fname: "First", 
		       ohip_num: 1234567899,
		       ohip_ver: 'PLL',
		       dob: '1971-01-01',
		       sex: 'M',
                       phone: "9999999999", 
                       mobile: "9999999999", 
		       addr: '77 Main str W',
		       city: 'Hamilton',
		       prov: 'ON',
		       postal: 'L9G1G1',
		       country: 'Canada',
		       hin_prov: 'ON',
		       hin_expiry: '2019-01-01'
		      )
    @visit = visits(:one)
  end

  test "object should be valid" do
    assert @pat.valid?
  end

  test "lname should be present" do
    @pat.lname = "     "
    assert_not @pat.valid?
  end

  test "lname should not be too long" do
    @pat.lname = "a" * 51
    assert_not @pat.valid?
  end

  test "ohip_num should be present" do
    @pat.ohip_num = nil
    assert_not @pat.valid?
  end

  test "ohip_num should be exactly 10 digits" do
    @pat.ohip_num = 123456789 
    assert_not @pat.valid?
  end

  test "ohip_num should be unique" do
    duplicate_user = @pat.dup
    @pat.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @pat.email = mixed_case_email
    @pat.save
    assert_equal mixed_case_email.downcase, @pat.reload.email
  end

  test "associated visits should be destroyed" do
    @pat.save
    @visit.patient_id = @pat.id 
    @visit.save
#   @pat.visits.create!(notes: "Lorem ipsum", doc_id: 1, doc_code:'l&', diag_code: '700.11', proc_code: 'A9', units: 1, fee: 29.99,  entry_ts: '2018-01-01 7:55:06')
    assert_difference 'Visit.count', -1 do
      @pat.destroy
    end
  end

end
