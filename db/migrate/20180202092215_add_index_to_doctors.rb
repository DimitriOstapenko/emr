class AddIndexToDoctors < ActiveRecord::Migration[5.1]
  def change
    add_index :doctors, :provider_no
  end
end
