class ChangePatIdColumnInVisits < ActiveRecord::Migration[5.1]
  def change
    rename_column :visits, :pat_id, :patient_id
  end
end
