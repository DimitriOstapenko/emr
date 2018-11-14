class CreateDistrictCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :district_codes do |t|
      t.string :code
      t.string :place
      t.string :type
      t.string :m_or_t
      t.string :county
      t.string :lhin

      t.timestamps
    end
  end
end
