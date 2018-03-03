class AddDateColumnsToReports < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :sdate, :date
    add_column :reports, :edate, :date
  end
end
