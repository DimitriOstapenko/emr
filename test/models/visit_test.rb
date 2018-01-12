require 'test_helper'

class VisitTest < ActiveSupport::TestCase
  def setup
    @patient = patients(:one)
    @doctor =  doctors(:one)
    @visit = Visit.new(notes: "Lorem ipsum", patient: @patient, doc_id: @doctor.id, date: '2018-01-07 7:55:06', diag_code: 702.22, proc_code: 'A09')
  end

  test "should be valid" do
    assert @visit.valid?
  end

  test "user id should be present" do
    @visit.patient = nil
    assert_not @visit.valid?
  end
  
  test "date should be present" do
    @visit.date = "   "
    assert_not @visit.valid?
  end

  test "diag_code should be present" do
    @visit.diag_code = "   "
    assert_not @visit.valid?
  end
  
  test "proc_code should be present" do
    @visit.proc_code = "   "
    assert_not @visit.valid?
  end


end
