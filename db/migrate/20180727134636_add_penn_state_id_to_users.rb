class AddPennStateIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :penn_state_identifier, :string
  end
end
