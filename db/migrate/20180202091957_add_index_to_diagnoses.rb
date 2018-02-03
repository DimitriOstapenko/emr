class AddIndexToDiagnoses < ActiveRecord::Migration[5.1]
  def change
    add_index :diagnoses, :code
  end
end
