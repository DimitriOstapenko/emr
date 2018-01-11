class AddAddressToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :addr, :string
    add_column :patients, :city, :string
    add_column :patients, :postal, :string
    add_column :patients, :prov, :string
  end
end
