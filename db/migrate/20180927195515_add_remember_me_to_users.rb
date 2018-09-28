class AddRememberMeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :remember_me, :boolean
  end
end
