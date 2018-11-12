class CreateReferrals < ActiveRecord::Migration[5.2]
  def change
    create_table :referrals do |t|
      t.integer :patient_id
      t.integer :doctor_id
      t.integer :visit_id
      t.date :date
      t.date :app_date
      t.string :filename
      t.string :to
      t.string :address_to
      t.string :from
      t.text :reason

      t.timestamps
    end
  end
end
