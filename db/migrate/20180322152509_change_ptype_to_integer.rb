class ChangePtypeToInteger < ActiveRecord::Migration[5.1]
  def change
	  change_column :procedures, :ptype, :integer #'integer USING CAST(ptype AS integer)'
  end
end
