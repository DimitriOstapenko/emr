require 'test_helper'

class DoctorTest < ActiveSupport::TestCase
   def setup
    @doc = Doctor.new( lname: "Last",
                       fname: "First",
		       cpso_num: 12345,
		       billing_num: 234567
                      )
  end

  test "should be valid" do
    assert @doc.valid?
  end

end
