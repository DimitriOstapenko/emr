class DropPatientMedsTable < ActiveRecord::Migration[5.2]
  def change
	  drop_table :patient_meds
  end
end
