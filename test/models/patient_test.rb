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
    @pat.ohip_num = 123
    assert_not @pat.valid?
  end

  test "ohip_num should be exactly 10 digits" do
    @pat.ohip_num = 123456789 
    assert_not @pat.valid?
  end

#  test "email validation should accept valid addresses" do
#    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
#                         first.last@foo.jp alice+bob@baz.cn]
#    valid_addresses.each do |valid_address|
#      @pat.email = valid_address
#      assert @pat.valid?, "#{valid_address.inspect} should be valid"
#    end
#  end

#  test "email validation should reject invalid addresses" do
#    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
#                           foo@bar_baz.com foo@bar+baz.com]
#    invalid_addresses.each do |invalid_address|
#      @pat.email = invalid_address
#      assert_not @pat.valid?, "#{invalid_address.inspect} should be invalid"
#    end
#  end

#  test "email addresses should be unique" do
#    duplicate_user = @pat.dup
#    duplicate_user.email = @pat.email.upcase
#    @pat.save
#    assert_not duplicate_user.valid?
#  end

#  test "email addresses should be saved as lower-case" do
#    mixed_case_email = "Foo@ExAMPle.CoM"
#    @pat.email = mixed_case_email
#    @pat.save
#    assert_equal mixed_case_email.downcase, @pat.reload.email
#  end

  test "associated visits should be destroyed" do
    @pat.save
    @pat.visits.create!(notes: "Lorem ipsum", doc_id: 1, patient_id: 1, diag_code: '700.11', proc_code: 'A9', entry_ts: '2018-01-01 7:55:06')
    assert_difference 'Visit.count', -1 do
    @pat.destroy
    end
  end

end
