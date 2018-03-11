class AddColumnsToProcedures < ActiveRecord::Migration[5.1]
  def change
    add_column :procedures, :prov_fee, :integer
    add_column :procedures, :ass_fee, :integer
    add_column :procedures, :spec_fee, :integer
    add_column :procedures, :ana_fee, :integer
    add_column :procedures, :non_ana_fee, :integer
  end
end
