class RemoveSexFromPatients < ActiveRecord::Migration[5.1]
  def self.up
    remove_column :patients, :sex
  end
end
