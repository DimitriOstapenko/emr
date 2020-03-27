class AddNewPatientToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :new_patient, :boolean, default: false
  end
end
