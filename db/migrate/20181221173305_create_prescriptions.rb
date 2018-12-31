class CreatePrescriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :prescriptions do |t|
      t.integer :visit_id
      t.text :meds, array: true, default: [].to_yaml
      t.integer :repeats
      t.integer :qty
      t.integer :duration
      t.text :note
      t.references :patient, foreign_key: true

      t.timestamps
    end
    add_index :prescriptions, [:patient_id, :created_at]
  end
end
