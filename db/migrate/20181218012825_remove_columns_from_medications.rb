class RemoveColumnsFromMedications < ActiveRecord::Migration[5.2]
  def change
	  remove_column :medications, :quantity, :integer
	  remove_column :medications, :repeats, :integer
  end
end
