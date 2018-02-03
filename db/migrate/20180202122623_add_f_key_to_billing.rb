class AddFKeyToBilling < ActiveRecord::Migration[5.1]
  def change
#    add_reference :billings, :visit, foreign_key: true
    add_foreign_key :billings, :visit
  end
end
