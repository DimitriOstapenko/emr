class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.references :visit, foreign_key: true
      t.string :document

      t.timestamps
    end
  end
end
