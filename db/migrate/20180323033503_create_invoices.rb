class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.string :pat_id
      t.integer :billto
      t.integer :visit_id
      t.decimal :amount
      t.text :notes

      t.timestamps
    end
  end
end
