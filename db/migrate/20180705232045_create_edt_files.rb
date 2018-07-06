class CreateEdtFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :edt_files do |t|
      t.integer :type
      t.string :name
      t.string :pathname
      t.date :upload_date
      t.integer :lines
      t.string :provider_no
      t.string :group_no
      t.integer :claims
      t.float :total_amount
      t.text :body

      t.timestamps
    end
  end
end
