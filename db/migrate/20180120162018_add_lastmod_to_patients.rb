class AddLastmodToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :lastmod_by, :string
  end
end
