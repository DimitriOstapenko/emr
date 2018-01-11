class AddIndexToPatients < ActiveRecord::Migration[5.1]
  def change
	  add_index :patients, :lname
  end
end
