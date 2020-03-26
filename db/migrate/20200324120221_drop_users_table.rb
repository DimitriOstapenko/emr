class DropUsersTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
