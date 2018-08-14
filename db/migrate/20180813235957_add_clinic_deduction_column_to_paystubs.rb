class AddClinicDeductionColumnToPaystubs < ActiveRecord::Migration[5.1]
  def change
    add_column :paystubs, :clinic_deduction, :float
  end
end
