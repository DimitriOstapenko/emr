class DropChartFileColumnFromPatients < ActiveRecord::Migration[5.2]
  def change
    remove_column :patients, :chart_file, :string
  end
end
