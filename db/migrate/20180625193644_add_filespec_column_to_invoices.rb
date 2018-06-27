class AddFilespecColumnToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :filespec, :string
  end
end
