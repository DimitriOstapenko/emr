class AddIndexToDailyCharts < ActiveRecord::Migration[5.1]
  def change
    add_index :daily_charts, :date
    add_index :daily_charts, :filename
  end
end
