class ChangeColumnInVisits < ActiveRecord::Migration[5.1]
  def change
	  rename_column :visits, :patient_id, :pat_id
	  rename_column :billings, :pat_code, :pat_id
	  rename_column :diagnoses, :diag_code, :code
	  rename_column :diagnoses, :diag_descr, :descr
  end
end
