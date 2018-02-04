class AddFeeColumn4ToVisits < ActiveRecord::Migration[5.1]
  def change
	  add_column :visits, :fee4, :float, default: 0.0
    add_column :visits, :units4, :integer, default: 0
  end
end
