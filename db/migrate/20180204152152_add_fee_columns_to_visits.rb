class AddFeeColumnsToVisits < ActiveRecord::Migration[5.1]
  def change
	  add_column :visits, :fee, :float, default: 0.0 
	  add_column :visits, :fee2, :float, default: 0.0
	  add_column :visits, :fee3, :float, default: 0.0
    add_column :visits, :units, :integer, default: 0
    add_column :visits, :units2, :integer, default: 0
    add_column :visits, :units3, :integer, default: 0
  end
end
