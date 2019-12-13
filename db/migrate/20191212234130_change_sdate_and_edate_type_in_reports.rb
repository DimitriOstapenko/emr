class ChangeSdateAndEdateTypeInReports < ActiveRecord::Migration[5.2]
  def change
    change_column :reports, :sdate, :datetime
    change_column :reports, :edate, :datetime
  end
end
