class ChangePatientDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :patient_docs, :doc_type, :integer
    remove_column :patient_docs, :app_date, :date
    rename_column :patient_docs, :filename, :patient_doc
  end
end
