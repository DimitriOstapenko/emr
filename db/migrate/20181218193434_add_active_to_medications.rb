class AddActiveToMedications < ActiveRecord::Migration[5.2]
  def change
    add_column :medications, :active, :boolean
  end
end
