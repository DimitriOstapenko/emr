class AddColumnToLetters < ActiveRecord::Migration[5.2]
  def change
    add_column :letters, :from, :string
  end
end
