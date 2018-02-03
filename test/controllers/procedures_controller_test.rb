require 'test_helper'

class ProceduresControllerTest < ActionDispatch::IntegrationTest

  def setup
    @proc       = procedures(:one)
    @other_proc = procedures(:two)
  end

  test "should redirect index when not logged in" do
    get procedures_path
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
          patch procedure_path(@proc), params: { procedure: { code: @proc.code, 
						       	      descr: @proc.descr,
							      ptype: @proc.ptype,
							      cost: @proc.cost, 
							      unit: @proc.unit,
							      percent: @proc.percent,
							      eff_date: @proc.eff_date,
							      diag_req: @proc.diag_req
							  }}

    assert_not flash.empty?
    assert_redirected_to login_url
  end


#  test "should get new" do
#    get procedures_new_url
#    assert_response :success
#  end

#  test "should get show" do
#    get procedures_show_url
#    assert_response :success
#  end

#  test "should get index" do
#    get procedures_index_url
#    assert_response :success
#  end

#  test "should get edit" do
#    get procedures_edit_url
#    assert_response :success
#  end

end
