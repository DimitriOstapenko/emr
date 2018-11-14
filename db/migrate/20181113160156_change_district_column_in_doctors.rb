class ChangeDistrictColumnInDoctors < ActiveRecord::Migration[5.2]
  def change
    remove_column :doctors, :district, :string
    add_column :doctors, :district, :integer, default: 0
  end
end
