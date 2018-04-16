class AddExportFileColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :export_file, :string
  end
end
