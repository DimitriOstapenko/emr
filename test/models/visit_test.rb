require 'test_helper'

class VisitTest < ActiveSupport::TestCase
  def setup
    @patient = patients(:one)
    @doctor =  doctors(:one)
    @visit = @patient.visits.new(
	    	       notes: "Lorem ipsum",
		       diag_code: "702.22",
		       proc_code: 'A09',
		       units: 1,
		       fee: 29.99,
		       proc_code2: 'A10B',
		       units2: 1,
		       fee2: 12.99,
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
  
  test "doc_id should be present" do
    @visit.doc_id = nil
    assert_not @visit.valid?
  end
  
  test "doc_code should be present" do
    @visit.doc_code = nil
    assert_not @visit.valid?
  end
  
  test "entry_ts should be present" do
    @visit.entry_ts = ''
    assert_not @visit.valid?
  end

  test "diag_code should be present" do
    @visit.diag_code = nil
    assert_not @visit.valid?
  end
  
  test "proc_code should be present" do
    @visit.proc_code = "   "
    assert_not @visit.valid?
  end

  test "units should be positive integer" do
    @visit.units = 0.5
    assert_not @visit.valid?
  end
  

end
