class CreateProcedures < ActiveRecord::Migration[5.1]
  def change
    create_table :procedures do |t|
      t.string :code
      t.string :qcode
      t.string :ptype
      t.string :descr
      t.float :cost
      t.integer :unit
      t.boolean :fac_req
      t.boolean :adm_req
      t.boolean :diag_req
      t.boolean :ref_req
      t.integer :percent
      t.date :eff_date
      t.date :term_date

      t.timestamps
    end
    
    add_index :procedures, :code, unique: true

  end
end
