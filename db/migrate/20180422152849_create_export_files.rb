class CreateExportFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :export_files do |t|
      t.string :name
      t.date :sdate
      t.date :edate
      t.integer :ttl_claims
      t.integer :hcp_claims
      t.integer :rmb_claims
      t.integer :wcb_claims

      t.timestamps
    end
  end
end
