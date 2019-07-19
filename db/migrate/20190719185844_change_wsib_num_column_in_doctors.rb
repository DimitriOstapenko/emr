class ChangeWsibNumColumnInDoctors < ActiveRecord::Migration[5.2]
  def change
          remove_column :doctors, :wsib_num, :integer
          add_column :doctors, :wsib_num, :string, default: ''
  end
end
