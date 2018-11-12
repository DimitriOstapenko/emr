class DropColumnFromReferrals < ActiveRecord::Migration[5.2]
  def change
	  remove_column :referrals, :from, :string
  end
end
