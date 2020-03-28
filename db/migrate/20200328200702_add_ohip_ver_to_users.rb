class AddOhipVerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ohip_ver, :string
  end
end
