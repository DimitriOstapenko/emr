class AddColumnEntryTsToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :entry_ts, :datetime
  end
end
