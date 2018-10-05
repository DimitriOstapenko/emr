class DropEdtErrorFiles < ActiveRecord::Migration[5.2]
  def change
	  drop_table :edt_error_files
  end
end
