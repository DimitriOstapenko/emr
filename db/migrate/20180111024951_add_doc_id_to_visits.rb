class AddDocIdToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :doc_id, :integer
#    add_foreign_key :visits, :doctors
  end
end
