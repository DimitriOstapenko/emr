class AddDocCodeColumnToDoctors < ActiveRecord::Migration[5.1]
  def change
    add_column :doctors, :doc_code, :string
  end
end
