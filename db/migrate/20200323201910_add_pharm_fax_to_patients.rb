class AddPharmFaxToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :pharm_fax, :string
  end
end
