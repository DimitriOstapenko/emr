class AddDatePaidToClaims < ActiveRecord::Migration[5.1]
  def change
    add_column :claims, :date_paid, :date
  end
end
