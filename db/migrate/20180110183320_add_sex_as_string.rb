class AddSexAsString < ActiveRecord::Migration[5.1]
  def change
	  add_column :patients, :sex, :string
  end
end
