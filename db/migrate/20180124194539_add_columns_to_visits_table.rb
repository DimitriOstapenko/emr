class AddColumnsToVisitsTable < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :status, :integer
    add_column :visits, :duration, :integer
    add_column :visits, :vis_type, :string
    add_column :visits, :entry_by, :string
  end
end
