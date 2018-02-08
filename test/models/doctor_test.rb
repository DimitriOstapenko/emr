require 'test_helper'

class DoctorTest < ActiveSupport::TestCase
   def setup
    @doc = Doctor.new( lname: "Last",
                       fname: "First",
		       cpso_num: 12345,
		       billing_num: 234567,
		       service: 'GENP',
		       ph_type: 'GP',
		       district: 'G',
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
		       doc_code: 'l&'
                      )
  end

  test "should be valid" do
    assert @doc.valid?
  end

end

