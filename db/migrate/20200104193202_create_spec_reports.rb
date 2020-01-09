class CreateSpecReports < ActiveRecord::Migration[5.2]
  def change
    create_table :spec_reports do |t|
      t.references :patient, foreign_key: true
      t.references :doctor, foreign_key: true
      t.date :date
      t.date :app_date
      t.string :filename

      t.timestamps
    end
    add_index :spec_reports, [:patient_id, :doctor_id]
  end
end
