class ChangeWeekTypeInSchedule < ActiveRecord::Migration[5.2]
  def change
	  remove_column :schedules, :weeks, :text, array: true, default: [].to_yaml
	  add_column :schedules, :weeks, :string, array: true
  end
end
