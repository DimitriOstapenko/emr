class AddMaidNameToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :maid_name, :string
  end
end
