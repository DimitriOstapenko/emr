require 'test_helper'

class DiagnosisTest < ActiveSupport::TestCase

  def setup
    @diag = diagnoses(:one)
  end

  test "Object should be valid" do
	 if !@diag.valid?
	    puts @diag.errors.full_messages
	 end
         assert @diag.valid?
  end

  test "code should be present" do
    @diag.code = nil
    assert_not @diag.valid?
  end
  
  test "code should be unique" do
    duplicate_diag = @diag.dup
    @diag.save
    assert_not duplicate_diag.valid?
  end

  test "descr should be present" do
    @diag.descr = nil
    assert_not @diag.valid?
  end

end
