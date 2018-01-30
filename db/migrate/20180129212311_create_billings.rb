class CreateBillings < ActiveRecord::Migration[5.1]
  def change
    create_table :billings do |t|
      t.integer :pat_code
      t.string :doc_code
      t.date :visit_date
      t.integer :visit_id
      t.string :proc_code
      t.integer :proc_units
      t.float :fee
      t.string :btype 
      t.string :diag_code
      t.string :status
      t.float :amt_paid
      t.date :paid_date
      t.float :write_off
      t.string :submit_file
      t.integer :submit_year
      t.string :remit_file
      t.integer :remit_year
      t.string :mohref
      t.string :bill_prov
      t.string :submit_user
      t.datetime :submit_ts

      t.timestamps
    end
    add_index :billings, [:pat_code, :visit_date, :created_at] 
  end
end
