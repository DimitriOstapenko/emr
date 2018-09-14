class RenameTypeColumnInEdtFiles < ActiveRecord::Migration[5.1]
  def change
	  rename_column :edt_files, :type, :ftype
  end
end
