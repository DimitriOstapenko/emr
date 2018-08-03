class AddBillingRefColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :billing_ref, :string
  end
end
