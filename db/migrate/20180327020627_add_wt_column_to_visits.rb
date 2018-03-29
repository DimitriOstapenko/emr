class AddWtColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :weight, :real
  end
end
