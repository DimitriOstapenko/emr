class ChangeTypeForSex < ActiveRecord::Migration[5.1]
  def change
	  change_column(:patients, :sex, :string, limit: 1)
  end
end
