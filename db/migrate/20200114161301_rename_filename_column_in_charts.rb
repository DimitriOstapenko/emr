class RenameFilenameColumnInCharts < ActiveRecord::Migration[5.2]
  def change
     rename_column :charts, :filename, :chart
  end
end
