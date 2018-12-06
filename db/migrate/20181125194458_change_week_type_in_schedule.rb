class ChangeWeekTypeInSchedule < ActiveRecord::Migration[5.2]
  def change
	  remove_column :schedules, :week, :integer 
	  add_column :schedules, :weeks, :string, array: true
  end
end
