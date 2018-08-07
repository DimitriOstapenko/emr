class AddTimeframeInReports < ActiveRecord::Migration[5.1]
  def change
     add_column :reports, :timeframe, :integer
     change_column :reports, :rtype, :string
  end
end
