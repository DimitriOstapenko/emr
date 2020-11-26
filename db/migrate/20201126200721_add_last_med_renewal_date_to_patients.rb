class AddLastMedRenewalDateToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :latest_medication_renewal, :datetime
  end
end
