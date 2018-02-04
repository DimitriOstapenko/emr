class AddActiveColumnToProcedures < ActiveRecord::Migration[5.1]
  def change
    add_column :procedures, :active, :boolean, default: false
    add_column :diagnoses, :active, :boolean, default: false
  end
end
