class RemoveCabmdRefFromClaims < ActiveRecord::Migration[5.1]
  def change
    remove_column :claims, :cabmd_ref, :string
  end
end
