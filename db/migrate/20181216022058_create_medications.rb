class CreateMedications < ActiveRecord::Migration[5.2]
  def change
    create_table :medications do |t|
      t.integer :patient_id
      t.integer :doctor_id
      t.string :name
      t.string :generic_name
      t.string :strength
      t.string :dose
      t.string :route
      t.string :freq
      t.string :format
      t.integer :repeats
      t.date :date

      t.timestamps
    end
  end
end
