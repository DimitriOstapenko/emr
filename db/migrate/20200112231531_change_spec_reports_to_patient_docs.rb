class ChangeSpecReportsToPatientDocs < ActiveRecord::Migration[5.2]
  def change
    rename_table :spec_reports, :patient_docs
  end
end
