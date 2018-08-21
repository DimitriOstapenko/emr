class RemoveDocumentsColumnFromVisits < ActiveRecord::Migration[5.1]
  def change
	  remove_column :visits, :document, :string
  end
end
