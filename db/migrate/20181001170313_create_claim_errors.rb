class CreateClaimErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_errors do |t|
      t.string :code
      t.text :descr

      t.timestamps
    end
  end
end
