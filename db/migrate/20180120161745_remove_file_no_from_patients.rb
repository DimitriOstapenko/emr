class RemoveFileNoFromPatients < ActiveRecord::Migration[5.1]
  def change
    remove_column :patients, :file_no, :string
  end
end
