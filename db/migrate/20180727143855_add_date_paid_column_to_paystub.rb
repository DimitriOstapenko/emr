class AddDatePaidColumnToPaystub < ActiveRecord::Migration[5.1]
  def change
    add_column :paystubs, :date_paid, :date
  end
end
