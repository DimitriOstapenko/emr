class RenameFilespecColumnInInvoices < ActiveRecord::Migration[5.1]
  def change
	  rename_column :invoices, :filespec, :filename
  end
end
