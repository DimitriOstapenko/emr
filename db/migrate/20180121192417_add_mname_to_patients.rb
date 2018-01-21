class AddMnameToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :mname, :string
  end
end
