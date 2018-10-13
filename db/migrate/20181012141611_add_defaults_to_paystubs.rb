class AddDefaultsToPaystubs < ActiveRecord::Migration[5.2]
  def change
	  change_column :paystubs, :gross_amt, :float, default: 0.0
	  change_column :paystubs, :net_amt, :float, default: 0.0
	  change_column :paystubs, :ohip_amt, :float, default: 0.0
	  change_column :paystubs, :cash_amt, :float, default: 0.0
	  change_column :paystubs, :ifh_amt, :float, default: 0.0
	  change_column :paystubs, :monthly_premium_amt, :float, default: 0.0
	  change_column :paystubs, :hc_dep_amt, :float, default: 0.0
	  change_column :paystubs, :wcb_amt, :float, default: 0.0
	  change_column :paystubs, :mho_deduction, :float, default: 0.0
	  change_column :paystubs, :clinic_deduction, :float, default: 0.0
  end
end
