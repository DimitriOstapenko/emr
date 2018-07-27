class AddFilenameToPaystubs < ActiveRecord::Migration[5.1]
  def change
    add_column :paystubs, :filename, :string
  end
end
