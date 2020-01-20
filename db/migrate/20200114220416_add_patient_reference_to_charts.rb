class AddPatientReferenceToCharts < ActiveRecord::Migration[5.2]
  def change
#    add_reference :charts, :patient, foreign_key: true
     add_foreign_key :charts, :patients
  end
end
