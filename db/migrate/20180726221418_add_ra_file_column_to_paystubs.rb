class AddRaFileColumnToPaystubs < ActiveRecord::Migration[5.1]
  def change
    add_column :paystubs, :ra_file, :string
  end
end
