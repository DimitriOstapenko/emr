class AddChkAmtToPaystubs < ActiveRecord::Migration[5.2]
  def change
    add_column :paystubs, :chk_amt, :float
  end
end
