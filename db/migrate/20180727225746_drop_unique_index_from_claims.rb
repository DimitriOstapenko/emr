class DropUniqueIndexFromClaims < ActiveRecord::Migration[5.1]
  def change
    remove_index :claims, :claim_no
    add_index :claims, :claim_no
  end
end
