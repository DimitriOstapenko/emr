class AddWtColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :weight, :float
  end
end
