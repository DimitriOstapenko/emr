class RemoveDateFromVisits < ActiveRecord::Migration[5.1]
  def change
    remove_column :visits, :date, :datetime
  end
end
