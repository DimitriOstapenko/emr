class AddBillingFormatToDoctor < ActiveRecord::Migration[5.2]
  def change
    add_column :doctors, :billing_format, :integer
  end
end
