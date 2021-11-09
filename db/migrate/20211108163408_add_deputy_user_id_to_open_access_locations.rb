class AddDeputyUserIdToOpenAccessLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :open_access_locations, :deputy_user_id, :bigint, null: true
    add_index :open_access_locations, :deputy_user_id
    add_foreign_key :open_access_locations, :users,
      column: :deputy_user_id,
      name: :open_access_locations_deputy_user_id_fk
  end
end
