class ChangePtypeToInteger < ActiveRecord::Migration[5.1]
  def change
	  change_column :procedures, :ptype, :integer
  end
end
