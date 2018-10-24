class CreateUserPerformances < ActiveRecord::Migration[5.2]
  def change
    create_table :user_performances do |t|
      t.integer :user_id, null: false
      t.integer :performance_id, null: false

      t.timestamps
    end

    add_index :user_performances, :user_id
    add_index :user_performances, :performance_id

    add_foreign_key :user_performances, :users, on_delete: :cascade
    add_foreign_key :user_performances, :performances, on_delete: :cascade
  end
end
