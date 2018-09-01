class AddEntrytsIndexToVisits < ActiveRecord::Migration[5.1]
  def change
	  add_index :visits, :entry_ts
  end
end
