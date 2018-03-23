class AddDateColumnToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :date, :date
  end
end
