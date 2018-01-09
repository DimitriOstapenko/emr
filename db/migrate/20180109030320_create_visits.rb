class CreateVisits < ActiveRecord::Migration[5.1]
  def change
    create_table :visits do |t|
      t.datetime :date
      t.text :notes
      t.decimal :diag_code
      t.string :proc_code
      t.references :patient, foreign_key: true

      t.timestamps
    end
    add_index :visits, [:patient_id, :created_at]
  end
end
