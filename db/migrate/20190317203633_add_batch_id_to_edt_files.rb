class AddBatchIdToEdtFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :edt_files, :batch_id, :integer
  end
end
