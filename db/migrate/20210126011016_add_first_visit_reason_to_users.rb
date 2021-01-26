class AddFirstVisitReasonToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_visit_reason, :text
  end
end
