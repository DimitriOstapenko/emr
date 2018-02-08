require 'test_helper'

class ProcedureTest < ActiveSupport::TestCase
  
  def setup
       @proc = procedures(:one)
  end

  test "Object should be valid" do
         if !@proc.valid?
            puts @proc.errors.full_messages
         end
         assert @proc.valid?
  end

  test "ptype should be present" do
    @proc.ptype = nil
    assert_not @proc.valid?
  end
  
  test "ptype should be up to 5 chars long" do
    @proc.ptype = 'X'*6 
    assert_not @proc.valid?
  end

  test "code should be present" do
    @proc.code = nil
    assert_not @proc.valid?
  end
  
  test "code should be < 10 chars" do
    @proc.code = 'x'*11
    assert_not @proc.valid?
  end

  test "code should be unique" do
    duplicate_proc = @proc.dup
    @proc.save
    assert_not duplicate_proc.valid?
  end

  test "unit should be present" do
    @proc.unit = nil
    assert_not @proc.valid?
  end
  
  test "unit should be positive [0..20]" do
    @proc.unit = -1 
    assert_not @proc.valid?
    @proc.unit = 21 
    assert_not @proc.valid?
  end
  
  test "descr should be present" do
    @proc.descr = nil
    assert_not @proc.valid?
  end
  
  test "cost should be present" do
    @proc.cost = nil
    assert_not @proc.valid?
  end
  
  test "cost should be numeric" do
    @proc.cost = 'Abc'
    assert_not @proc.valid?
  end

  test "cost should be positive" do
    @proc.cost = -100.99
    assert_not @proc.valid?
  end


end
