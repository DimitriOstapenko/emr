class AddLastVisitDateToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :last_visit_date, :date
    add_index :patients, :last_visit_date
  end
end
