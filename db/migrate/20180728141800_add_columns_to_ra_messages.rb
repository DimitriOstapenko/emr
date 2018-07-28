class AddColumnsToRaMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :ra_messages, :group_no, :string
    add_column :ra_messages, :payee_name, :string
    add_column :ra_messages, :payee_addr, :string
    add_column :ra_messages, :amount, :integer
    add_column :ra_messages, :pay_method, :string
    add_column :ra_messages, :bil_agent, :string
  end
end
