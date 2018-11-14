class AddWsibColumnToDoctors < ActiveRecord::Migration[5.2]
  def change
    add_column :doctors, :wsib_num, :integer, default: 0
    add_column :doctors, :accepts_new_patients, :boolean, default: false
    remove_column :doctors, :billing_num, :integer
    remove_column :doctors, :ph_type, :string
    remove_column :doctors, :service, :string
  end
end
