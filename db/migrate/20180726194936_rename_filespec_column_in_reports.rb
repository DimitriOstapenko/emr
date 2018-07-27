class RenameFilespecColumnInReports < ActiveRecord::Migration[5.1]
  def change
	  rename_column :reports, :filespec, :filename
  end
end
