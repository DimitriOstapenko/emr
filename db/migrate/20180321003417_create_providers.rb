class CreateProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :addr1
      t.string :addr2
      t.string :city
      t.string :prov
      t.string :country
      t.string :postal
      t.string :phone1
      t.string :phone2
      t.string :fax
      t.string :email

      t.timestamps
    end
  end
end
