class ChangeColumnTypeInVisitsTable < ActiveRecord::Migration[5.1]
  def change
    change_column :visits, :diag_code, :string
  end
end
