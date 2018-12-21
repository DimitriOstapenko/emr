class AddDefaultToMedications < ActiveRecord::Migration[5.2]
  def change
	  change_column :medications, :active, :boolean, default: true
  end
end
