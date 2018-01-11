class AddCountryToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :country, :string
  end
end
