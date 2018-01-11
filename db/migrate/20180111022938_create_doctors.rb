class CreateDoctors < ActiveRecord::Migration[5.1]
  def change
    create_table :doctors do |t|
      t.string :lname
      t.string :fname
      t.integer :cpso_num
      t.integer :billing_num

      t.timestamps
    end
  end
end
