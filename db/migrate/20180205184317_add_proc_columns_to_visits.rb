class AddProcColumnsToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :proc_code2, :string
    add_column :visits, :proc_code3, :string
    add_column :visits, :proc_code4, :string
  end
end
