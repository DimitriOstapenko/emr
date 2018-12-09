class AddTotalsToRaMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :ra_messages, :claims, :integer
    add_column :ra_messages, :svcs, :integer
    add_column :ra_messages, :sum_claimed, :integer
    add_column :ra_messages, :sum_paid, :integer
  end
end
