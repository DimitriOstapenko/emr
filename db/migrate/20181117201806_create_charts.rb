class CreateCharts < ActiveRecord::Migration[5.2]
  def change
    create_table :charts do |t|
      t.integer :patient_id
      t.integer :doctor_id
      t.string :filename
      t.integer :pages

      t.timestamps
    end
  end
end
