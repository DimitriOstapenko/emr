class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.string :lname
      t.string :fname
      t.integer :sex
      t.string :ohip_num
      t.date :dob
      t.string :phone

      t.timestamps
    end
  end
end
