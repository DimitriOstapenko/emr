class ChangeVisitDateInBillings < ActiveRecord::Migration[5.2]
  def change
    change_column :billings, :visit_date, :datetime
  end
end
