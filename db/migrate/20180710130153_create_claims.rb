class CreateClaims < ActiveRecord::Migration[5.1]
  def change
    create_table :claims do |t|
      t.string :claim_no
      t.string :provider_no
      t.string :accounting_no
      t.string :pat_lname
      t.string :pat_fname
      t.string :province
      t.string :ohip_num
      t.string :ohip_ver
      t.string :pmt_pgm
      t.string :moh_group_id
      t.integer :visit_id
      t.string :ra_file
      t.date   :date_paid

      t.index ["claim_no"], name: "index_claims_on_claim_no", unique: true
      t.index ["accounting_no"], name: "index_claims_on_accounting_no"
      t.index ["cabmd_ref"], name: "index_claims_on_cabmd_ref"
      t.timestamps
    end
  end
end
