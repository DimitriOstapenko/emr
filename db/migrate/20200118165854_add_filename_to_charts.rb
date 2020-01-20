class AddFilenameToCharts < ActiveRecord::Migration[5.2]
  def change
    add_column :charts, :filename, :string
  end
end
