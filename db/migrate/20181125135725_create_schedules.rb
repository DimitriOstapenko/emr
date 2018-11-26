class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.integer :doctor_id
      t.integer :dow
      t.integer :week
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
