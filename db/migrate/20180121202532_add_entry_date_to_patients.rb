class AddEntryDateToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :entry_date, :date
  end
end
