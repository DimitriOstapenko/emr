class ChangeColumnNameInInvoices < ActiveRecord::Migration[5.1]
  def change
	  rename_column :invoices, :pat_id, :patient_id
  end
end
