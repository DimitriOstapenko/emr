class AddAmountToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :amount, :decimal, precision: 8, scale: 2
  end
end
