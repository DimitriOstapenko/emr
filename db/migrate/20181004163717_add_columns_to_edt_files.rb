class AddColumnsToEdtFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :edt_files, :doctors, :integer
    add_column :edt_files, :hcp_svcs, :integer
    add_column :edt_files, :rmb_svcs, :integer
    add_column :edt_files, :processed, :boolean, default: false
  end
end
