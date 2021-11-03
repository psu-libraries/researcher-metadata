class CreateDeputyAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :deputy_assignments do |t|
      t.references :primary_user, references: :users, foreign_key: { to_table: :users }
      t.references :deputy_user, references: :users, foreign_key: { to_table: :users }
      t.timestamp :deactivated_at, null: true
      t.boolean :is_active
      t.timestamp :confirmed_at, null: true

      t.timestamps
    end

    add_index :deputy_assignments, [:primary_user_id, :deputy_user_id], unique: true
  end
end
