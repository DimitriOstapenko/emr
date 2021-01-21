class CreateSvcMonitors < ActiveRecord::Migration[5.2]
  def change
    create_table :svc_monitors do |t|
      t.string :name
      t.boolean :up

      t.timestamps
    end
  end
end
