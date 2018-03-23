class AddColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :provider_id, :integer
  end
end
