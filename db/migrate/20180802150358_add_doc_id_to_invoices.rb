class AddDocIdToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :doctor_id, :integer
  end
end
