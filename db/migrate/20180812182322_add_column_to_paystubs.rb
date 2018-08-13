class AddColumnToPaystubs < ActiveRecord::Migration[5.1]
  def change
    add_column :paystubs, :mho_deduction, :float
  end
end
