class CreateLetters < ActiveRecord::Migration[5.2]
  def change
    create_table :letters do |t|
      t.string :title
      t.integer :patient_id
      t.integer :visit_id
      t.integer :doctor_id
      t.date :date
      t.string :filename
      t.string :to
      t.string :address_to
      t.text :body
      t.text :note

      t.timestamps
    end
  end
end
