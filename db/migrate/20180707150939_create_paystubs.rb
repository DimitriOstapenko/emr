class CreatePaystubs < ActiveRecord::Migration[5.1]
  def change
    create_table :paystubs do |t|
      t.integer :doc_id
      t.integer :year
      t.integer :month
      t.integer :claims
      t.integer :services
      t.float :gross_amt
      t.float :net_amt
      t.float :ohip_amt
      t.float :cash_amt
      t.float :ifh_amt
      t.float :monthly_premium_amt
      t.float :hc_dep_amt

      t.timestamps
    end
  end
end
