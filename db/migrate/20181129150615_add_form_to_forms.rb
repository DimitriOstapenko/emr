class AddFormToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :form, :string
  end
end
