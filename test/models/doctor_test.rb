require 'test_helper'

class DoctorTest < ActiveSupport::TestCase
   def setup
    @doc = Doctor.new( lname: "Last",
                       fname: "First",
		       cpso_num: 12345,
		       bills: true,
		       address: "1 John st",
		       city: 'Hamilton',
		       prov: 'ON',
		       postal: 'L1L1L1',
		       phone: '999-999-9999',
		       mobile: '111-111-1111',
		       licence_no: '1234567',
		       note: 'Good doctor',
		       office: '1 Main St W',
		       provider_no: "123456",
		       group_no: "1234",
		       specialty: '00',
		       email: 'doc@doc.com',
		       fax: '999-888-9999',
		       wsib_num: 12345,
		       district: 101,
		       percent_deduction: 30,
		       accepts_new_patients: true
                      )
  end

  test "should be valid" do
    assert @doc.valid?
  end

end

