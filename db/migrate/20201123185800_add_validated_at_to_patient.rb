class AddValidatedAtToPatient < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :validated_at, :datetime
  end
end
