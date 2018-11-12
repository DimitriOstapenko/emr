class AddColumnsToReferrals < ActiveRecord::Migration[5.2]
  def change
    add_column :referrals, :to_phone, :string
    add_column :referrals, :to_fax, :string
    add_column :referrals, :to_email, :string
    remove_column :referrals, :to, :string
    add_column :referrals, :to_doctor_id, :integer
  end
end
