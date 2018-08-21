class AddDocumentsToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :document, :string
    remove_column :visits, :documents, :json
  end
end
