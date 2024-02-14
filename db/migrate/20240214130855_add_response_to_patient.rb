class AddResponseToPatient < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :response, :text
  end
end
