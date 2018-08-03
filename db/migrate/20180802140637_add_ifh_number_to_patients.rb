class AddIfhNumberToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :ifh_number, :string
  end
end
