class CreateDailyCharts < ActiveRecord::Migration[5.1]
  def change
    create_table :daily_charts do |t|
      t.string :filename
      t.date :date
      t.integer :pages

      t.timestamps
    end
  end
end
