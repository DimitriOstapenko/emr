class AddPercentDeductionToDoctors < ActiveRecord::Migration[5.1]
  def change
    add_column :doctors, :percent_deduction, :integer
  end
end
