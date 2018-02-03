require 'test_helper'

class BillingTest < ActiveSupport::TestCase

  def setup
    @bill = Billing.new(pat_id: 1,
                        doc_code: 'l&',
                        visit_date: "2009-12-31", 
                        visit_id: 100, 
                        proc_code: 'A003',
                        proc_units: 1, 
			fee: 29.99,
                        btype: 'HCP',
			diag_code: '595.300',
			status: 'PAID BY MOH',
			amt_paid: 29.99,
			paid_date: "2010-01-05",
			write_off: 0.0,
			submit_file: "Submit_file",
			remit_file: "Remit_file",
			remit_year: 2010,
			mohref: "MOH Ref",
                        bill_prov: 'ON',
                        submit_user: 'HS',
                        submit_ts: '2009-12-31 18:10:15',
			doc_id: 100
                       )
  end
  
  test "object should be valid" do
    assert @bill.valid?
  end

  test "visit_date should be present" do
    @bill.visit_date = "   "
    assert_not @bill.valid?
  end

  test "doc_code should be present" do
    @bill.doc_code = " "
    assert_not @bill.valid?
  end
  
  test "doc_id should be present" do
    @bill.doc_id = nil
    assert_not @bill.valid?
  end

  test "pat_id should be present" do
    @bill.pat_id = nil
    assert_not @bill.valid?
  end

  test "diag_code should be present" do
    @bill.diag_code = nil
    assert_not @bill.valid?
  end

  test "proc_code should be present" do
    @bill.proc_code = nil
    assert_not @bill.valid?
  end

  test "visit_id should be present" do
    @bill.visit_id = nil
    assert_not @bill.valid?
  end

  test "fee should be present" do
    @bill.fee = nil
    assert_not @bill.valid?
  end

end
