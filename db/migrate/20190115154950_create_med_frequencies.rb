class CreateMedFrequencies < ActiveRecord::Migration[5.2]
  def change
    create_table :med_frequencies do |t|
      t.string :name
      t.string :descr

      t.timestamps
    end
  end
end
