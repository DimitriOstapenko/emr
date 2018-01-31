class AddColumnToBillings < ActiveRecord::Migration[5.1]
  def change
    add_column :billings, :doc_id, :integer
  end
end
