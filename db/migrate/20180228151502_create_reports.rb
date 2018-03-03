class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.string :name
      t.integer :doc_id
      t.integer :rtype
      t.string :filespec

      t.timestamps
    end
  end
end
