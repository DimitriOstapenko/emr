class CreateRaErrcodes < ActiveRecord::Migration[5.1]
  def change
    create_table :ra_errcodes do |t|
      t.string :code
      t.string :message

      t.timestamps
    end
  end
end
