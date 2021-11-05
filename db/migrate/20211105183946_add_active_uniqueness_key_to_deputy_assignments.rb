class AddActiveUniquenessKeyToDeputyAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :deputy_assignments, :active_uniqueness_key, :bigint, default: 0

    add_index :deputy_assignments, [:primary_user_id, :deputy_user_id, :active_uniqueness_key],
      unique: true,
      name: 'index_deputy_assignments_on_unique_users_if_active'
  end
end
