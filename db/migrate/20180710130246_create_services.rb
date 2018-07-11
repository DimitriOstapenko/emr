class CreateServices < ActiveRecord::Migration[5.1]
  def change
    create_table :services do |t|
      t.string :claim_no
      t.integer :tr_type
      t.date :svc_date
      t.integer :units
      t.string :svc_code
      t.integer :amt_subm
      t.integer :amt_paid
      t.string :errcode

      t.references :claim, foreign_key: true

      t.index ["claim_no"], name: "index_services_on_claim_no"
      t.timestamps
    end
  end
end
