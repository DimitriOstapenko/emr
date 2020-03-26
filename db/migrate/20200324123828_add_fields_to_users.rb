class AddFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :role, :integer
    add_column :users, :name, :string
    add_reference :users, :patient, foreign_key: true
    add_column :users, :invited_by, :string, default: nil
  end
end
