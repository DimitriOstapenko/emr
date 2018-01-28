class AddDocCodeColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :doc_code, :string
  end
end
