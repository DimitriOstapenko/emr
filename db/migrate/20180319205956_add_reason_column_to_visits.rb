class AddReasonColumnToVisits < ActiveRecord::Migration[5.1]
  def change
    add_column :visits, :reason, :string
  end
end
