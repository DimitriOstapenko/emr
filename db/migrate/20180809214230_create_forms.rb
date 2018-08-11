class CreateForms < ActiveRecord::Migration[5.1]
  def change
    create_table :forms do |t|
      t.string :name
      t.string :descr
      t.integer :ftype
      t.string :filename
      t.integer :format
      t.date :eff_date
      t.boolean :fillable

      t.timestamps
    end
  end
end
