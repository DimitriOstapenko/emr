class AddColumnToDoctors < ActiveRecord::Migration[5.2]
  def change
    add_column :doctors, :fax, :string
  end
end
