class AddDocumentToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :document, :string
  end
end
