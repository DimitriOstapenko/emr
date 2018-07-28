class CreateRaMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_messages do |t|
      t.text :msg_text
      t.string :ra_file
      t.date :date_paid

      t.timestamps
    end
    add_index :ra_messages, :date_paid
  end
end
