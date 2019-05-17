class AddPattypeAndHinnumToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :pat_type, :string
    add_column :visits, :hin_num, :string
  end
end
