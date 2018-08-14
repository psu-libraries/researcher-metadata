class AddUniqueIndexOnPennStateIdentifierForUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :penn_state_identifier, unique: true
  end
end
