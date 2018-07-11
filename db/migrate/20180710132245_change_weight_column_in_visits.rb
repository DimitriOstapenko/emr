class ChangeWeightColumnInVisits < ActiveRecord::Migration[5.1]
  def change
	  change_column :visits, :weight, :float
  end
end
