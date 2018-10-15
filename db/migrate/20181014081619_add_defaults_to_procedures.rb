class AddDefaultsToProcedures < ActiveRecord::Migration[5.2]
  def change
	  change_column :procedures, :cost, :float, default: 0.0
	  change_column :procedures, :unit, :integer, default: 1
	  change_column :procedures, :fac_req, :boolean, default: false
	  change_column :procedures, :adm_req, :boolean, default: false
	  change_column :procedures, :diag_req, :boolean, default: false
	  change_column :procedures, :ref_req, :boolean, default: false
	  change_column :procedures, :percent, :integer, default: 0
	  change_column :procedures, :prov_fee, :float, default: 0.0
	  change_column :procedures, :ass_fee, :float, default: 0.0
	  change_column :procedures, :spec_fee, :float, default: 0.0
	  change_column :procedures, :ana_fee, :float, default: 0.0
	  change_column :procedures, :non_ana_fee, :float, default: 0.0
  end
end
