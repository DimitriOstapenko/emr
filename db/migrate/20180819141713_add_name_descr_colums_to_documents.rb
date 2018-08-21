class AddNameDescrColumsToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :name, :string
    add_column :documents, :description, :string
    add_column :documents, :dtype, :integer
  end
end
