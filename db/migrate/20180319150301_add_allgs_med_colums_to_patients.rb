class AddAllgsMedColumsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :allergies, :string
    add_column :patients, :medications, :string
  end
end
