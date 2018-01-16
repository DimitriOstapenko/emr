class AddColumnsToDoctors < ActiveRecord::Migration[5.1]
  def change
    add_column :doctors, :service, :string
    add_column :doctors, :ph_type, :string
    add_column :doctors, :district, :string
    add_column :doctors, :bills, :boolean
    add_column :doctors, :address, :string
    add_column :doctors, :city, :string
    add_column :doctors, :prov, :string
    add_column :doctors, :postal, :string
    add_column :doctors, :phone, :string
    add_column :doctors, :mobile, :string
    add_column :doctors, :licence_no, :string
    add_column :doctors, :note, :text
    add_column :doctors, :office, :string
    add_column :doctors, :provider_no, :string
    add_column :doctors, :group_no, :string
    add_column :doctors, :specialty, :string
    add_column :doctors, :email, :string
  end
end
