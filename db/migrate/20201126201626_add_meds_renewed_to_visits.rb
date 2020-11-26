class AddMedsRenewedToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :meds_renewed, :boolean, default: false
  end
end
