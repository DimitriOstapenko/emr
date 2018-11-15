class DropTypeFromDistrict < ActiveRecord::Migration[5.2]
  def change
	  remove_column :district_codes, :type, :string
	  add_column :district_codes, :dtype, :string
  end
end
