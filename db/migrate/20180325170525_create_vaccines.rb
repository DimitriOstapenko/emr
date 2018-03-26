class CreateVaccines < ActiveRecord::Migration[5.1]
  def change
    create_table :vaccines do |t|
      t.string :name
      t.string :target
      t.string :route
      t.string :dose
      t.string :din
      t.text :notes

      t.timestamps
    end
  end
end
