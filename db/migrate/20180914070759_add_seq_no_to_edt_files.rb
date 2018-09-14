class AddSeqNoToEdtFiles < ActiveRecord::Migration[5.1]
  def change
    add_column :edt_files, :seq_no, :integer
    rename_column :edt_files, :name, :filename
    remove_column :edt_files, :pathname, :string
  end
end
