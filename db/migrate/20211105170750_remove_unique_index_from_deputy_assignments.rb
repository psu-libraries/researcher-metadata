class RemoveUniqueIndexFromDeputyAssignments < ActiveRecord::Migration[5.2]
  def change
    remove_index :deputy_assignments, [:primary_user_id, :deputy_user_id]
  end
end
