class ChangeColumnsInPrescriptions < ActiveRecord::Migration[5.2]
  def change
      remove_column :prescriptions, :repeats, :integer
      remove_column :prescriptions, :qty, :integer
      remove_column :prescriptions, :duration, :integer
      add_column :prescriptions, :repeats, :string, array: true, default: []
      add_column :prescriptions, :qty, :string, array: true, default: []
      add_column :prescriptions, :duration, :string, array: true, default: []
  end
end
