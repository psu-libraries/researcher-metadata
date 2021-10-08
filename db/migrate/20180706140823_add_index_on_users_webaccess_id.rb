class AddIndexOnUsersWebaccessId < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :webaccess_id
  end
end
