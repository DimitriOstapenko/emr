class CreateRaAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_accounts do |t|
      t.string :tr_code
      t.date :tr_date
      t.integer :tr_amt
      t.string :tr_msg
      t.string :ra_file
      t.date :date_paid

      t.timestamps
    end
    add_index :ra_accounts, :date_paid
  end
end
