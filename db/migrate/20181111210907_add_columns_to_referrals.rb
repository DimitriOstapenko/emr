class AddColumnsToReferrals < ActiveRecord::Migration[5.2]
  def change
    add_column :referrals, :to_phone, :string
    add_column :referrals, :to_fax, :string
    add_column :referrals, :to_email, :string
    change_column :referrals, :to, :integer
    rename_column :referrals, :to, :to_doctor_id
  end
end
