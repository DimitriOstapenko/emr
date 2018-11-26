require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  def setup
    @doctor =  doctors(:one)
    @schedule = Schedule.new(
	doctor_id: @doctor.id,
        start_time: '9:00',
	end_time: '14:00',
        dow: 0,
	weeks: [1,3] 
        )
  end

  test "Object should be valid" do
         assert @schedule.valid?
  end

  test "doctor_id should be present" do
    @schedule.doctor_id = nil
    assert_not @schedule.valid?
  end

end
