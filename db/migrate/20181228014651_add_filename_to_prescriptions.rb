class AddFilenameToPrescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :prescriptions, :filename, :string
  end
end
