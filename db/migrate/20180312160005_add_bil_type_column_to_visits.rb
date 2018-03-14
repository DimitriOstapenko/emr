class AddBilTypeColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :bil_type, :integer
  end
end
