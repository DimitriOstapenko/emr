class AddQuantityToMedications < ActiveRecord::Migration[5.2]
  def change
    add_column :medications, :quantity, :integer
    remove_column :medications, :generic_name, :string
  end
end
