require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test "full title helper" do
    assert_equal full_title,        "Walk-In EMR" 
    assert_equal full_title("Help"), "Help | Walk-In EMR"
  end

end
