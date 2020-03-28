class AddConsentedToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :consented, :boolean, default: false
  end
end
