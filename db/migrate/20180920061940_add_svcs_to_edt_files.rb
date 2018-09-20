class AddSvcsToEdtFiles < ActiveRecord::Migration[5.1]
  def change
    add_column :edt_files, :services, :integer
  end
end
