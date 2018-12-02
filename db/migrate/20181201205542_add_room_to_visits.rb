class AddRoomToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :room, :integer, default: 0
  end
end
