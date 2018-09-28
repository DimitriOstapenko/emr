class AddClinicPatToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :clinic_pat, :boolean
  end
end
