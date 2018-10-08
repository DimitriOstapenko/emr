class AddDefaultToDocsInEdtFiles < ActiveRecord::Migration[5.2]
def up
  change_column :edt_files, :doctors, :integer, default: 1
end

def down
  change_column :edt_files, :doctors, :integer, default: nil
end

end
