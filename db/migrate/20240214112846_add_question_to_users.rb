class AddQuestionToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :patients, :question, :string
  end
end
