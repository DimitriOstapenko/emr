class CreateDiagnoses < ActiveRecord::Migration[5.1]
  def change
    create_table :diagnoses do |t|
      t.string :diag_code
      t.string :diag_descr
      t.string :prob_type

      t.timestamps
    end
  end
end
