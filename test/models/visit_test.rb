require 'test_helper'

class VisitTest < ActiveSupport::TestCase
  def setup
    @patient = patients(:one)
    @doctor =  doctors(:one)
    @visit = @patient.visits.new(notes: "Lorem ipsum",
		       diag_code: "702.22",
		       proc_code: 'A09',
		       patient_id: @patient.id,
		       doc_id: @doctor.id,
		       doc_code: @doctor.doc_code,
		       status: 4,
		       duration: 10,
		       vis_type: 'WI',
		       entry_by: 'HS',
		       entry_ts: '2018-01-07 7:55:06'
		      )
  end

  test "Object should be valid" do
    assert @visit.valid?
  end

  test "patient_id should be present" do
    @visit.patient_id = nil
    assert_not @visit.valid?
  end
  
  test "entry_ts should be present" do
    @visit.entry_ts = ''
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
