class AddClaimIdColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :claim_id, :integer
  end
end
