class AddDoctorIdToPrescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :prescriptions, :doctor_id, :integer
  end
end
