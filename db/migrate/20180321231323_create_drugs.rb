class CreateDrugs < ActiveRecord::Migration[5.1]
  def change
    create_table :drugs do |t|
      t.string :name
      t.string :dnum
      t.string :strength
      t.string :dose
      t.string :freq
      t.string :amount
      t.string :status
      t.string :generic
      t.string :igcodes
      t.string :format
      t.string :route
      t.integer :dur_cnt
      t.string :dur_unit
      t.integer :refills
      t.integer :cost
      t.string :lu_code
      t.string :pharmacy
      t.string :aliases
      t.string :dtype
      t.boolean :odb
      t.string :filename
      t.text :notes
      t.text :instructions

      t.timestamps
    end
  end
end
