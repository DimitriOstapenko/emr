class RenameMedicationsInPatients < ActiveRecord::Migration[5.2]
  def change
	  rename_column :patients, :medications, :meds
  end
end
