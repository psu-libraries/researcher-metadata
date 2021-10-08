class AddPureUuidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pure_uuid, :string
    add_index :users, :pure_uuid, unique: true
  end
end
