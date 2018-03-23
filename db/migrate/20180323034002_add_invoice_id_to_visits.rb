class AddInvoiceIdToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :invoice_id, :integer
  end
end
