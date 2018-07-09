class AddWcbColumnToPaystubs < ActiveRecord::Migration[5.1]
  def change
    add_column :paystubs, :wcb_amt, :float
  end
end
