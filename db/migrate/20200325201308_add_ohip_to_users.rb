class AddOhipToUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :name, :ohip_num
  end
end
