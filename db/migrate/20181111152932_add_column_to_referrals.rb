class AddColumnToReferrals < ActiveRecord::Migration[5.2]
  def change
    add_column :referrals, :note, :text
  end
end
