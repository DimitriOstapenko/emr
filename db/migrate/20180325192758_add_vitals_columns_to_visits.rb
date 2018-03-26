class AddVitalsColumnsToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :temp, :integer
    add_column :visits, :bp, :string
    add_column :visits, :pulse, :integer
  end
end
