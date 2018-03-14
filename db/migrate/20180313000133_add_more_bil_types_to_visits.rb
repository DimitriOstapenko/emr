class AddMoreBilTypesToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :bil_type2, :integer
    add_column :visits, :bil_type3, :integer
    add_column :visits, :bil_type4, :integer
  end
end
