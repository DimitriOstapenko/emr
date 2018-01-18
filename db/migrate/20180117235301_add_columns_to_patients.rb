class AddColumnsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :ohip_ver, :string
    add_column :patients, :hin_prov, :string
    add_column :patients, :hin_expiry, :date
    add_column :patients, :pat_type, :string
    add_column :patients, :pharmacy, :string
    add_column :patients, :pharm_phone, :string
    add_column :patients, :file_no, :string
    add_column :patients, :notes, :text
    add_column :patients, :alt_contact_name, :string
    add_column :patients, :alt_contact_phone, :string
    add_column :patients, :email, :string
    add_column :patients, :chart_file, :string
    add_column :patients, :family_dr, :string
    add_column :patients, :mobile, :string
    add_index :patients, :mobile
    add_index :patients, :email
    add_index :patients, :file_no
    add_index :patients, :pat_type
    add_index :patients, :ohip_num
    add_index :patients, :phone
  end
end
